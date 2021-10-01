---
title: Sock ShopのCloudFormation TemplateをTerraformとPulumiに移植した
date: 2021-10-01 23:00:00 +0900
---

[Microservices Demo: Sock Shop](https://microservices-demo.github.io/)の CloudFormation Templateを[TerraformとPulumiに移植](https://github.com/mizzy/sock-shop)したので、それに関するメモを残しておく。

---

## モチベーション

最近仕事ではTerraformを触っている時間が一番多いので、研究もこの辺りのツールに関連する技術を対象とした方が良いのでは、と考えた。研究を行うためには、類似ツールの比較が必要だし、比較のためには、サンプルコード程度のものではなく、実際の環境に近い状態を再現できるコードが必要、というのが移植のモチベーションになっている。

---

## 移植元コード

[Deployment on Amazon EC/2 Container Service](https://microservices-demo.github.io/deployment/ecs.html)にAmazon ECSへのデプロイ手順が載っているが、肝心のCloudFormation Templateは、[元リポジトリ](https://github.com/microservices-demo/microservices-demo)ではDeplicated扱いで[削除されている](https://github.com/microservices-demo/microservices-demo/commit/b738dd548aae972)。



なので、[markfink-splunk/sock-shop: Deployments of the Weaveworks Sock Shop application instrumented with SignalFx.](https://github.com/markfink-splunk/sock-shop)にあるファイル([ecs-fargate/cfn-stack-app-only.yaml](https://github.com/markfink-splunk/sock-shop/blob/master/ecs-fargate/cfn-stack-app-only.yaml))を移植元コードとして使うことにした。

---

## デプロイ環境

個人用に使っている検証用AWSアカウント、惰性で使っていてぐちゃぐちゃになってきたので、いったん不要なリソースを全削除して、[AWS Organizations](https://aws.amazon.com/jp/organizations/)でマルチアカウント化、[AWS Single Sign-On](https://aws.amazon.com/jp/single-sign-on/)で各アカウントにSSOできるようにした。

アカウント管理用のTerraformコード、最初はprivateにしていたけど、別に見えてまずい情報もないな、と思ったので[publicにした](https://github.com/mizzy/aws-accounts)。

これにより、CloudFormation、Terraform、Pulumiそれぞれの検証環境をアカウントごと分離できるようにした。

---

## CloudFormation Templateのデプロイ

まずは大元となるCloudFormation Templateがデプロイできるものになっていないと話にならないので、ここから着手。元ファイルのままでは動かなかったり、そのままでは不便なところなどあったので、微修正している。差分は以下の通り。

{% gist 37401088bc6e3564addf7a27d698f6fb %}


---

## Terraformへの移植

CloudFormation Templateがデプロイできたところで、Terraformへの移植を行った。移植はおおまかには以下のような手順で行った。

1. リソースをひとつ選び、Terraformコードで必須Argumentだけ指定したリソースを定義。
2. terraform importでCloudFormation用アカウント上のリソースをimport。
3. terraform planでCloudFormation用アカウント上のリソースとの差分を確認し、差分がなくなるよう必須以外のArtumentsを記述。
4. 差分がなくなったらTerraform用アカウントにterraform applyしてリソースを作成。

上記の作業を80ほどあるリソース全てに対して行った。

[Terraformer](https://github.com/GoogleCloudPlatform/terraformer)はいまいち使い勝手が悪いし、ひとつひとつどのようなリソースがあるか確認しておいた方が、後々捗りそうなので、人力で移植した。

先日行われた[HashiTalks: 日本](https://events.hashicorp.com/hashitalksjapan)での、Quipperの鈴木さんのプレゼンで知った[tfmigrator](https://github.com/tfmigrator/tfmigrator)を使えば、Terraformerのいまいちさを補えたっぽいので、今度機会があれば使ってみたい。

Terraformerがどういまいち使い勝手が悪いのか、とか、tfmigratorの使い方なんかは、[鈴木さんのブログエントリ](https://techblog.szksh.cloud/tfmigrator/)に詳しく書いてあるので、興味ある方はこちらからどうぞ。

移植の最終確認として、Terraform用アカウントにapplyしたリソースをいったんdestroyして、最初から全リソースのapplyを行った。

が、上記手順4で「差分がなくなるよう必須以外のArgumentsを記述」とあるが、planで差分がなくなっても、別アカウントにapplyすると、明示してないArgumentが原因でうまくapplyできないリソースがあったので、その辺りの修正を行った。

---

## Pulumiへの移植

Pulumiへの移植も、Terraformへの移植と同様に、CloudFormation用アカウント上のリソースをひとつひとつインポートしながら進めていった。

[tf2pulumi](https://www.pulumi.com/tf2pulumi/)や[cf2pulumi](https://www.pulumi.com/cf2pulumi/)といったツールもオフィシャルに提供されているけど、自分がわかりやすいようにコードやファイルを分割したかったので、これらのツールは使わなかった。

PulumiはTypeScript、JavaScript、Python、Go、C#から記述言語が選べるが、この中で一番慣れているGoで記述を行った。

[Pulumiのリソースインポート](https://www.pulumi.com/docs/guides/adopting/import/)は、Terraformと違いコードの生成まで行ってくれる。

たとえば、

```
 $ pulumi import aws:cloudwatch/logGroup:LogGroup \
  sock_shop \
  sock-shop
```

といったコマンドでCloudWatch Logs log groupをインポートすると、以下のようなコードを吐いてくれる。

{% gist 98fa264604cfd23bee559e83499f4cda %}

ただ、`pulumi import`ではエラーになってうまくインポートできない場合もあり、そういう場合は、先に以下の様なコードを書いてから、`pulumi up`を実行してインポートした。最後の`pulumi.Import()`がポイント。

{% gist 6aad2ff46fe3045f05c5c2f9a52a5c78 %}

また、希に`pulumi import`が吐くコードが間違っていることもあって、そういう場合は手で修正を行った。

Pulumi、サンプルコード程度しか触ったことがなかったけど、今回の移植作業でだいぶ把握できた気がする。

---

## まとめ

最初の方でもリンクを張っているけど、移植したコードは[ここに置いてあります](https://github.com/mizzy/sock-shop)。
