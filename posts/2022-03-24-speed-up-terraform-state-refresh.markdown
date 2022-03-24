---
title: Terraform State Refreshの高速化手法と実装
date: 2022-03-24 12:00:00 +0900
---

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>


## TerraformのState

TerraformのStateとは、Terraformで管理しているリソースの状態をJSONで記述したものであり、ファイルとして永続化されている。

Stateが何のためにあるのか、については[オフィシャルな解説](https://www.terraform.io/language/state/purpose)があるので詳しく説明はしないが、Stateには主に以下の目的がある。

- Mapping to the Real World
- Metadata
- Performance
- Syncing

このエントリでは、Performanceに着目する。

---

## State Refresh

Terraformは、plan/applyを実行する際に、どのような変更を行う必要があるのかを決定するために、リソースの最新の状態を知る必要がある。 デフォルトの動作では、plan/applyを実行するたびに、すべてのリソースの最新の状態を取得しにいく。

これがState Refreshである。

State Refreshは、例えばAWS上のリソースを管理している場合は、リソースひとつひとつに対してAWSのAPIにリクエストを投げ、情報を取得する。また、リソースの種類によっては、ひとつのリソースに対して複数のAPIリクエストを投げることもある。

そのため、Terraformで管理しているリソースの数に応じてAPIリクエストの回数が増え、Refreshにかかる時間が増える。APIにはRate Limitもあるので、並列にリクエストを投げて高速化するのも限界がある。

管理しているリソースの数が少なければ、Refreshにかかる時間は問題にならないが、多い場合にはちょっとした変更を確認したいだけの場合でも、State Refreshで数分待たされることになる。

---

## State Refreshを高速化する手法

Terraformコードをサブディレクトリに分けStateを分割することで、State Refreshを高速にする、という手法が一般的に使われている。Stateの分割によりRefreshの高速化は見込めるが、細分化しすぎると運用管理が煩雑になる。

また、[オフィシャルな解説](https://www.terraform.io/language/state/purpose)では、リソースの数が多い場合は、`-refresh=false`や`-target`オプションを利用することで、Refreshに時間がかかるのを回避する、といった記述がある。

`-refresh=false`オプションの場合には、ファイルに永続化されたStateを正とみなし、APIリクエストを投げて最新の情報を取得するようなことはしない。また、`-target`オプションでは、指定したリソース（と依存関係のあるリソース）のみAPIリクエストを投げて最新の情報を取得するが、それ以外のリソースについては、ファイルに永続化されたStateを正とみなす。

しかし、`-refresh=false`は、Terraform外でリソースに変更があった場合はそれを検知できない。また、`-target`オプションはRefresh対象となるリソースをいちいち指定しないといけない上に、指定外のリソースについては、Terraform外で変更があっても検知できない。

そこで、State Refresh高速化のための手法として、以下の手法について考えてみる。

- Terraform外で変更されたリソースを予め永続化されたStateに反映しておく。
- Terraform実行時にRefresh対象となるリソースを絞る。

それぞれについて掘りさげる。

---

## Terraform外で変更されたリソースを予め永続化されたStateに反映しておく（その1）

ファイルに永続化されているStateが常に最新の状態になっていれば、`-refresh=false`オプションでRefreshをスキップしても、最新の状態が得られる。これにより、terraform plan/applyのState Refreshにかかる時間を0にすることができる。

これを実現する方法のひとつとして、以下のようなやり方が考えられる。

- リソースの変更を何らかの方法で検知する。
- 変更を検知したリソースがTerraform管理対象のリソースである場合、永続化されたStateに情報を反映する。

AWSのリソースをTerraformで管理している、という前提の元では、具体的には以下のような実装が考えられる。

```mermaid
flowchart LR
terraform[Lambda Function]
event[CloudWatch Events]
s3[S3 Bucket]
event -- 1 --> terraform
terraform -- 2 --> s3
```

1. CloudWatch Eventsがリソースの変更イベントを発火
2. Lambda Functionが変更イベントを受け取り、変更されたリソースがTerraform管理下にある場合、`terraform refresh -target`でStateを更新して保存


コンセプト実装として、[tfrefresh](https://github.com/mizzy/tfrefresh)というものをつくってみた。

詳細は省くが、様々な面で実装や運用がかなり面倒ということがわかり、この手法はあまり実用的ではない、という判断に至った。

---

## Terraform外で変更されたリソースを予め永続化Stateに反映しておく（その2）

その1のやり方は、常にリソース変更イベントを監視し、リアルタイムに最新の情報を永続化Stateに反映する、という仕組みを維持管理する必要があり、運用の手間がかかる。

Terraformユーザから見れば、永続化Stateは常にリアルタイムに最新の状態を反映している必要はなく、Terraform実行時に最新の状態を反映していれば良い。そこで、AWSのリソースをTerraformで管理している、という前提で、次のような実装を考える。

```mermaid
flowchart LR
cloudtrail[CloudTrail]
s3[S3 Bucket]
program[State Update Program]

cloudtrail -- 1 --> program
program -- 2 --> s3
```

1. Terraform実行時にState Update Programが、永続化Stateの最終更新日時以降に変更されたリソースをCloudTrailログから取得。
   - このプログラムは、Terraformに組み込む、あるいはラッパースクリプト化するなどして、terraform plan/apply実行前に必ず動くようにする。
2. State Update Programが、1.で取得したリソースに対して`terraform refresh -target`でStateを更新して保存。その後terraform plan/applyが実行される。

このようにすると、Terraform実行前に、永続化Stateが最新の状態に更新されるため、`-refresh=false`オプションを利用して、State Refreshにかかる時間を0にすることができる。

こちらも詳細は省くが、そもそも永続化されたStateが最新更新日時を持っていないなど、Terraformの仕様上実装が困難ということがわかった。また、実装できたとしても、Terraform実行の直前にログからRefresh対象を判別し永続化Stateを更新するため、状況によってはかえって時間がかかる可能性もある。

---

## Terraform実行時にRefresh対象となるリソースを絞る

先に挙げた、予め永続化Stateに最新の情報を反映しておくのとは別なやり方として、Terraform実行時にRefresh対象となるリソースを絞るやり方を考える。

これは[オフィシャルな解説](https://www.terraform.io/language/state/purpose)にある`-refresh=false`や`-target`オプションを利用した回避方法そのものであるが、オプションの指定を人が判断して行うのではなく、プログラムが判断する。

Refresh対象となるリソースをどのように判別するかであるが、ここでは、Terraformコードはバージョン管理システムで管理されており、ベースブランチのTerraformコードは常にapplyされた状態である、という前提の元、ベースブランチ上のファイルとカレントディレクトリ上のファイルを比較し、差分のあるリソースを抽出してRefresh対象とする。

これを行うためのツールとして、[tfdiff](https://github.com/mizzy/tfdiff)というツールを実装してみた。tfdiffは、ベースブランチ上のファイルとカレントディレクトリ上のファイルを比較し、リソースに差分がない場合には`-refresh=false`という文字列を出力、差分がある場合には、該当リソースすべてについて`-target resource_name`という文字列を出力する。

tfdiffは`terraform plan $(tfdiff)`といった形で、terraformコマンドと組み合わせて利用する。

たとえば、tfdiffがリソースに差分がないと判断すれば、`terraform plan -refresh=false`が実行されるし、`aws_s3_bucket.foo`と`aws_iam_user.bar`に差分があると判断すれば、`terraform plan -target aws_s3_bucket.foo -target aws_iam_user.bar`が実行される。

これにより、Refresh対象となるリソースが必要なものだけに絞り込まれるので、Refresh時間を短縮することができる。

現在のtfdiffは250行ほどの雑なコードで、不十分なところも色々あるが、実装の労力に対して得られる効果は、先の2つの手法よりも大きく、利用のための敷居も低い。

ただしこのやり方では、差分のあるリソース、すなわち変更対象であるリソース（と依存関係にあるリソース）の情報は最新のものが得られるが、それ以外のリソースの情報は古いままである可能性が捨てきれない。冒頭で述べた、「Terraformは、plan/applyを実行する際に、どのような変更を行う必要があるのかを決定するために、リソースの最新の状態を知る必要がある。」という目的のためには十分であるが、Terraform以外のツール（[ecspresso](https://github.com/kayac/ecspresso)や[lambroll](https://github.com/fujiwara/lambroll)など）からStateを参照する際には、古い情報を参照してしまう可能性がある。

---

## まとめ

- Terraform State Refreshを高速化する手法や実装について、現在考えていることを整理してみた。
- リアルタイム、あるいは必要なタイミング(Terraform実行時)にStateを最新の状態にする、という手法は、現在考えつく限りでは、実装や運用が困難である。
- バージョン管理システムを活用して、Terraform実行時にRefresh対象を絞る、という手法は、前提条件はあるものの、実装や利用が比較的容易である。ただし、変更対象外のリソースはRefreshされないため、ファイルに永続化されたState上には古い情報が残る可能性がある。
