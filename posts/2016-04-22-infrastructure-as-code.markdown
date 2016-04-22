---
title: Infrastructure as Code 再考
date: 2016-04-22 09:00:00 +0900
---

Infrastructure as Code という言葉が現れてから少なくとも8年ほど経過しており、この言葉もすっかり定着したように見えるが、[Martin Fowler](https://www.thoughtworks.com/profiles/martin-fowler) 氏が最近自身のブログで [Infrastructure as Code について触れており](http://martinfowler.com/bliki/InfrastructureAsCode.html) 、また、氏の同僚である [Kief Morris](https://www.thoughtworks.com/profiles/kief-morris) 氏が O'Reilly Media から [Infrastructure as Code という本を出す](http://shop.oreilly.com/product/0636920039297.do)（現在 Early Relase 版や [Free Chapters](https://info.thoughtworks.com/Infrastructure-as-Code-Kief-Morris.html) が入手できる）ようなので、このタイミングで改めて Infrastructure as Code について、その歴史を振り返るとともに、現在の状況について整理してみようと思い、このエントリを書くことにした。

内容的には、以前書いた [インフラ系技術の流れ](http://mizzy.org/blog/2013/10/29/1/) と若干重複してる部分もある。

そういえば日本でも最近、[サーバ/インフラエンジニア養成読本 DevOps編 [Infrastructure as Code を実践するノウハウが満載! ]](http://gihyo.jp/book/2016/978-4-7741-7993-3) というムック本が出ていますね。

----

## Infrastructure as Code とは

Infrastructure as Code が何かについては、既に色んな人が色んなところで語っているので、ここでは詳しくは説明しない。簡単に言えば「インフラ」をコードで記述することによって、ソフトウェアシステムで既に有効であると立証されているプラクティスを、インフラにも同じように適用でき、その恩恵が受けられる、というもの。

このプラクティスには次のようなものがある。

* バージョン管理
* 繰り返し可能なビルド
* テスト
* 継続的インテグレーション
* 継続的デプロイ

とは言え、最初から Infrastructure as Code がこのように解釈されていたわけではなく、その意味合いは時が経つとともに変遷している。

----

## Infrastructure as Code の歴史と変遷

Infrastructure as Code という言葉が現れ、今のように定着するようになるまでの大まかな流れを振り返ると、その起源は1993年に登場した [CFEngine](https://cfengine.com/) にまで遡れる。もちろん当時は Infrastructure as Code という言葉はなかったが、[Puppet](https://puppet.com/) や [Chef](https://www.chef.io/) といった Configuration Management Tools と呼ばれるものの元祖であり、現在の Infrastructure as Code の流れに与えた影響は大きい。

Infrastructure as Code という言葉の大元の出自は調べてみてもわからなかったが、2005年に Puppet が登場したことが、この言葉が現れる直接のきっかけになったと思われる。

Chef がきっかけじゃないの？と思う人がいるかもしれない。Infrastructure as Code という言葉がどのタイミングで現れたのか調べてみると、一番古い資料では、現在 Chef 社の CTO である [Adam Jacob](https://twitter.com/adamhjk) 氏 が、2008年4月25日に公開したスライド [Why Startups Need Automated Infrastructures の 24ページ目](http://www.slideshare.net/adamhjk/why-startups-need-automated-infrastructures/24-Steps_to_Launch_Configuration_Management) が見つかる。

しかし、Chef のリリースは2009年であり、このスライドには Puppet は載っているけれど Chef は載っていない。また、Adam Jcob 氏の所属が HJK Solutions となっており、Chef 社の前身である Opscode 社を立ち上げる前であることが窺える。

なので流れ的には、CFEngine の影響を受けた Puppet が登場 → Puppet が広く受け入れられる → Puppet のような Configuration Management 手法を Infrastructure as Code と呼ぼうと誰かが言った（もしかして Adam Jcob 氏？） → Puppet Alternative として Adam Jcob 氏が Chef を開発した、といった感じなのではないかと。

Chefの [Initial Commit が 2008年3月6日](https://github.com/chef/chef/commit/b5117775e86cff40399187b6292c98fba9dc5034) で、上記スライドを公開する少し前なので、Infrastructure as Code という言葉の発案者が Adam Jcob 氏だとすると、この言葉を思いついたのと、Chef（最初は Marionette という名前だった）の着想を得て開発を始めたのはほぼ同じ頃かもしれない。

英語版が2010年6月、日本語版が2011年5月に出版された書籍『[ウェブオペレーション](http://www.oreilly.co.jp/books/9784873114934/)』で、Adam Jacob 氏は Infrastructure as Code を「ソースコードリポジトリ・アプリケーションデータのバックアップ・サーバリソースからビジネスを復旧できるようにすること」と述べており、当時はディザスタリカバリ的な視点から Infrastructure as Code を捉えていたようだ。

ちなみに、以下は ChefConf 2014 で Adam Jcob 氏と撮影したツーショット写真。

![](https://pbs.twimg.com/media/BxzvOikCIAEcTGR.jpg:large)

ただ、Adam Jcob 氏のスライドのタイトルには「Automated」とある通り、Infrastructure as Code のメリットは、当初は「自動化」に焦点が当てられていたものと思われる。

それが現在のように、ソフトウェアシステムのプラクティスをインフラに適用する、という意味合いに変化したのは、DevOps という考え方と結びついたためだろう。

DevOps という言葉は、[Patrick Debois](http://www.jedi.be/) 氏が主催した [Devopsdays Ghent 2009](http://www.devopsdays.org/events/2009-ghent/) が発端であり、同氏は Agile 2008 Conference で [Agile infrastructures and operations: how infra-gike are you? (PDF)](http://www.jedi.be/presentations/IEEE-Agile-Infrastructure.pdf) という発表を行っている。このことからも、DevOps はアジャイルの流れを汲んでいることが窺える。なので、Infrastructure as Code が DevOps と結びついてきた結果、アジャイル的なプラクティスをインフラにも適用する、という流れが生まれたのだと思われる。

Infrastructure as Code という言葉の出始めは2008年、DevOps は2009年だが、2009年当時にすぐに Infrastructure as Code が DevOps と結びついて今のような意味合いとなったわけではない。2009年6月に公開されたスライド [10+ Deploys Per Day: Dev and Ops Cooperation at Flickr の22ページ目](http://www.slideshare.net/jallspaw/10-deploys-per-day-dev-and-ops-cooperation-at-flickr/22-CFengineChef_BCfg2_FAI1_Automated_infrastructure) でも「Automated infrastructure」とあることから、この当時もまだ、主にインフラの自動化に焦点が当てられていたようだ。

単なる自動化から、ソフトウェアシステムのプラクティス適用、という流れに変わったのは、2011年6月に O'Reilly Media から出た [Test-Driven Infrastructure with Chef](http://shop.oreilly.com/product/0636920020042.do) がきっかけだと思われる（ちなみに現在は [第二版](http://shop.oreilly.com/product/0636920030973.do) が出ている）。この本が「Test-Driven Infrastructure」という具体的なプラクティスが認知され広まるきっかけとなったのだろう。

「テスト駆動」という具体的なプラクティスが登場したことにより、「継続的インテグレーション」や「継続的デプロイ」といった他のプラクティスにも広がっていき、Infrastructure as Code が今のような意味合いとして捉えられるようになっていった。

2013年3月に登場した [Serverspec](http://serverspec.org/) もこの流れを加速するのに一役買っている。

----

## Infrastructure as Code の適用領域

[インフラ系技術の流れ](http://mizzy.org/blog/2013/10/29/1/) では、サーバプロビジョニングの領域を、次の3つにわける考え方を紹介した。

* Orchestration
* Configuration
* Bootstrapping

Infrastructure as Code は元々、CFEngine の影響を受けた Puppet が登場した流れから出てきた言葉であり、CFEngine も Puppet も Configuration レイヤーに該当するツールである。したがって Infrastructure as Code の対象領域は Configuration レイヤーであり、代表的なツールと言えば Puppet や Chef であった。実際、Infrastructure as Code という言葉を聞くと、真っ先に思い浮かぶのは Chef、という方が多いのではないだろうか。

ところが最近では、Bootstrapping の領域も Infrastructure as Code の対象範囲に含まれている。

[Amazon EC2](https://aws.amazon.com/jp/ec2/) のような、API でプログラマブルに扱える IaaS は結構前からある（確か EC2 登場は2006年）が、インフラをコードでプログラマブルに扱えるから Infrastructure as Code だ、という見方はあまりなかったように思われる。

その状況が変わったのはおそらく、[Terraform](https://www.terraform.io/) や [CloudFormation](https://aws.amazon.com/jp/cloudformation/) といった、API を直接操作することなく、何らかの簡易的な言語によって IaaS を操作できるツールやサービスが登場したことが影響しているだろう。

ちなみに、以下は Terraform を開発している [HashiCorp](https://www.hashicorp.com/) 社の CEO [Mitchell Hashimoto](https://twitter.com/mitchellh) 氏と撮影したツーショット写真。

<img src="/images/2016/04/mhashimoto.png" style="width: 600px;" />

また、単なるインフラ管理の自動化から、ソフトウェアシステムにおけるプラクティスの応用、と意味合いが変わるにつれ、Infrastructure as Code と聞いて想起するものが、Puppet, Chef, Terraform といった、インフラをコードで記述するツールだけではなく、[Test Kitchen](http://kitchen.ci/) や [Serverspec](http://serverspec.org/)、[Jenkins](https://jenkins.io/) や [CircleCI](https://circleci.com/) といった、Infrastructure as Code のプラクティスを支えるツールやサービスなど、多岐に渡るようになってきている。

Configuration Management を対象としていた Infrastructure as Code が、更に低いレイヤー、よりインフラと呼ぶにふさわしい領域も含むようになったことで、元々 Infrastructure as Code が対象としていた領域については、 Configuration as Code と呼び分けた方が良いのでは、といった議論も最近は出てきている。

が、現在使われている「インフラ」という言葉の指す範囲は広く、Configuration Management が対象とする領域も含まれているし、元々 Configuration をメインの対象としてい た Infrastructure as Code を Configuration as Code に変え、その下のレイヤーだけを Infrastructure as Code と呼ぶ、というのは、混乱を招きそう。

また、Configuration as Code の字面だけを見ると、設定内容をコードで書く（例: Nginx の設定を mruby で書く）ことを自分は想起する。

なにより、Infrastructure as Code は、ソフトウェアシステムのプラクティスを、今まで適用範囲外だと思われていた領域に適用する、というパラダイムを表す言葉として重要でなのであって、その中でレイヤーを厳密に細分化して区別する意味合いは薄いと思われる。


----

## Infrastructure as Code に関連するツールやサービスの分類

書籍『[Infrastructure as Code](http://shop.oreilly.com/product/0636920039297.do)』では、Infrastructure as Code に関連するツールやサービスを次の4つのグループに分類している。

* Dynamic Infrastructure Platforms
  * EC2 のような IaaS や [OpenStack](https://www.openstack.org/) のような IaaS を構成するためのツール
* Infrastructure Orchestration Tools
  * Terraform や CloudFormation のような、IaaS 上でサーバ/ネットワーク/ストレージといったリソースを制御するためのツールやサービス
  * [Consul](https://www.consul.io/), [etcd](https://coreos.com/etcd/), [ZooKeeper](https://zookeeper.apache.org/) のような Configuration Registry
* Server Configuration Tools
  * Puppet, Chef, [Ansible](https://www.ansible.com/), [Itamae](https://github.com/itamae-kitchen/itamae) といったリソースの設定を行うためのツール
* Infrastructure Services
  * プロビジョニングしたインフラを管理するためのツール
  * モニタリング、サービスディスカバリ、プロセス・ジョブ管理、ソフトウェアデプロイメントなど

前項で、Infrastructure as Code と Configuration as Code を分離する意味はあまりない、と述べたが、ツールをこのように分類するのは、各ツールの役割がイメージしやすいし、Infrastructure as Code のライフサイクルを整理したり、各フェーズについて議論したりするのには有用そうだ。

Dynamic Infrastucture Platforms の上で、Infrastructure Orchestration Tools によりサーバ/ネットワーク/ストレージといったリソースの割り当てを行い、Server Configuration Tools でそれらリソースの設定を行う。そして Infrastructure Services によってリソースを管理する。というのがざっくりとした流れ。

この中で Infrastructure as Code 的な手法が適用できるツールが揃っているのは、今のところ Infrastructure Orchestration Tools と Server Configuration Tools ぐらいか。

Dynamic Infrastructure はその名の通り基盤であり、その上でリソースをコントロールするツールは Infrastructure Orchestration に属するので、Dynamic Infrastruture Tools に属する Infrastructure as Code なツールがないのはある意味当然かな、と。

Infrastructure Services はその性質上、静的なコードを記述して制御する、というよりも、Infrastructure Orchestration Tools や Server Configuration Tools と連動して動的に何かを行う、というものが多そうなので、Infrastructure as Code なツールがあまりないのはそのためかも。今後、この辺りで Infrasturcture as Code 的なツールや手法がどう発展していくのかが気になる。あるいは発展しないかも。

----

## Infrastructure as Code に関するイベントやります

最初に触れたように、Martin Fowler 氏がブログでとりあげたり、O'Reilly から書籍が出る、ということもあって、改めて Infrastructure as Code について振り返って現状整理してみた。整理はしてみたものの、この先どうなっていくのか、といったことはまだ十分考察できていないし、一人で考えていても煮詰まりそうなので、Infrastructure as Code をテーマにしたイベントでもやろうかと考えている。

[Infrastructure as Code 現状確認会](http://www.zusaar.com/event/11697003) というイベントが過去にあったので、これとは少し違う方向性で、ツールの話が主眼ではなく、もう少し大局的な視点から、Infrastructure as Code のこれまでとこれからについて語れるようなイベントを。

もし興味があったり、こんな話が聞きたい、などあれば、ブコメや Twitter などでお知らせ頂けるとありがたいです。
