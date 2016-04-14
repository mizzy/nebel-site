---
title: Infrastructure as Code 再考
date: 2016-04-04 14:39:14 +0900
---

Infrastructure as Code という言葉が現れてから少なくとも8年ほど経過しており、この言葉もすっかり定着したように見えるが、[Martin Fowler](https://www.thoughtworks.com/profiles/martin-fowler) 氏が最近自身のブログで [Infrastructure as Code について触れており](http://martinfowler.com/bliki/InfrastructureAsCode.html) 、また、氏の同僚である [Kief Morris](https://www.thoughtworks.com/profiles/kief-morris) 氏が O'Reilly Media から [Infrastructure as Code という本を出す](http://shop.oreilly.com/product/0636920039297.do)（現在 Early Relase 版や [Free Chapters](https://info.thoughtworks.com/Infrastructure-as-Code-Kief-Morris.html) が入手できる）ようなので、このタイミングで改めて Infrastructure as Code について、その歴史を振り返るとともに、現在の状況について整理してみようと思い、このエントリを書くことにした。

内容的には、以前書いた [インフラ系技術の流れ](http://mizzy.org/blog/2013/10/29/1/) と若干重複してる部分もあるけど、Infrastructure as Code については軽く触れているだけなので、このエントリでは深く掘り下げてみる。

そういえば日本でも最近、[サーバ/インフラエンジニア養成読本 DevOps編 [Infrastructure as Code を実践するノウハウが満載! ]](http://gihyo.jp/book/2016/978-4-7741-7993-3) というムック本が出ていますね。

----

## Infrastructure as Code とは

Infrastructure as Code が何かについては、既に色んな人が色んなところで語っているので、ここでは詳しくは説明しない。簡単に言えば「インフラ」をコードで記述することによって、ソフトウェアシステムで既に有効であるとされるプラクティスを、インフラにも同じように適用でき、その恩恵が受けられる、というもの。

このプラクティスには以下のようなものがある。

* バージョン管理
* 繰り返し可能なビルド
* テスト
* 継続的インテグレーション
* 継続的デプロイ

とは言え、最初から Infrastructure as Code がこのように解釈されていたわけではなく、時が経つにつれて変遷してる。

----

## Infrastructure as Code の歴史と変遷

Infrastructure as Code という言葉が現れ、今のように定着するようになるまでの大まかな流れを振り返ると、その起源は1993年に登場した [CFEngine](https://cfengine.com/) にまで遡れるだろう。もちろん当時は Infrastructure as Code という言葉はなかったが、Puppet や Chef といった Configuration Management Tool と呼ばれるものの元祖であり、現在の Infrastructure as Code の流れに与えた影響は計り知れない。

Infrastructure as Code という言葉の大元の出自は調べてみてもわからなかったが、2005 年に Puppet が登場し、[Puppet: Next-Generation Configuration Management](https://www.usenix.org/publications/login/february-2006-volume-31-number-1/puppet-next-generation-configuration-management) 


Puppet

Agile infrastructure and operations

Chefの登場 何年だっけ？

EC2

naoya さんの Kindle 本

DevOps




冒頭に「Infrastructure as Code という言葉が現れてから少なくとも8年ほど経過」と書いている。その根拠は、現在 Chef 社の CTO である Adam Jacob 氏 が、2008年4月25日に公開したスライド [Why Startups Need Automated Infrastructures の 24ページ目](http://www.slideshare.net/adamhjk/why-startups-need-automated-infrastructures/24-Steps_to_Launch_Configuration_Management) に「Infrastructure as Code」という記載があるから。

これより古い資料は見つけられなかった。おそらく2008年あたりに出てきた言葉なのだろう。Adam Jacob 氏がこの言葉の発案者なのかそうでないのかは、調べてみてもわからなかった。

この時点では、スライドのタイトルに「Automated」とある通り、Infrastructure as Code のメリットは「自動化」に焦点が当てられていたものと思われる。

少し遡って、2007年6月から約1年にわたって [gihyo.jp](http://gihyo.jp/) で [オープンソースなシステム自動管理ツール Puppet](http://gihyo.jp/admin/serial/01/puppet) という連載記事を書かせてもらっていたが、この時の自分も、主に自動化に焦点を当てており、現在の Infrastructure as Code のプラクティスのひとつである「バージョン管理」については、軽く触れるに留め、前面に押し出してはいなかった。

更に少し前、Puppet を使い始めた流れで、Puppet マニフェスト適用後のサーバの状態をテストするための、Assurer という Perl 製のツールを開発していた。その時に「テスト駆動サーバ構築」という言葉を考え出しており、今の「テスト駆動インフラ」と同じ概念を、9年ほど前に既に構想していた。[こちらのブログエントリのコメント](http://d.hatena.ne.jp/dayflower/20070405/1175782564#c1175823666) にその証拠が残っている。


英語版が2010年6月、日本語版が2011年5月に出版された書籍『[ウェブオペレーション](http://www.oreilly.co.jp/books/9784873114934/)』で、Adam Jacob 氏は Infrastructure as Code を**「ソースコードリポジトリ・アプリケーションデータのバックアップ・サーバリソースからビジネスを復旧できるようにすること」**と述べており、ディザスタリカバリ的な視点から Infrastructure as Code を捉えていることが窺える。

ちなみに、以下は ChefConf 2014 で Adam Jcob 氏と撮影したツーショット写真。

![](https://pbs.twimg.com/media/BxzvOikCIAEcTGR.jpg:large)

2011年6月には、O'Reilly Media から [Test-Driven Infrastructure with Chef](http://shop.oreilly.com/product/0636920020042.do) の第一版が出ている（現在は第二版が出ている）。この頃から「テスト駆動インフラ」という概念が出始めた模様。

また、[DevOpsDays Tokyo 2012に参加してきたので聞いたこととか思ったことまとめ - As a Futurist...](https://blog.riywo.com/2012/05/27/145310/) という2012年5月のエントリには「インフラCI」という言葉が出てきており、自分がこの言葉を見聞きしたのは、これが初めてだったように記憶してる。

自分が Serverspec をリリースしたのは2013年3月。「テスト駆動インフラ」や「インフラCI」をやろうとしたけど、既存のツールでは用途に合わなかったため、自分で開発することにした。

Infrastructure as Code は、単にインフラをコードで記述して自動化するだけではなく、ソフトウェアシステムのプラクティスをインフラにも適用することだ、という現在の考え方は、既に存在していたテスト駆動インフラやインフラCIという概念が広まり、それにアジャイルや DevOps が絡むことによってできあがった考え方だろう。それを推し進めるのに Serverspec は一役買ったと思っている。

更に継続的デプロイにまで発展
Agile Infrastructure/Agile Operations
アジャイル -> テスト駆動や継続的インテグレーション
DevOps -> Dev と Ops の融合
元々syadminから注目されてたのが、アジャイルやDevOps方面からも注目


元々 Configuration Management の領域で生まれた言葉であり、今でも IaC と言えば Chef, Ansible, Puppet, Itame あたりの CMT を真っ先に思い浮かべる人も多いだろうが、現在は Configuration Management 以外の領域、特に IaaS あたりにも適用できる。これは Terraform といったツールの登場が大きい。領域については次の項で詳しく見る。





----

## Infrastructure as Code 適用領域の分類

上述のスライドの、Infrastructure as Code という言葉が書かれたページ上には、Puppet, Cfengine, Bcfg2 といったいわゆる「Configuration Management Tools」が挙げられているように、元々は Infrastructure as Code ＝ Configuration Managemennt Tools という図式であった。今でもおそらく、Infrastructure as Code と言えば、Chef、Puppet、Ansible、Itamae といった Configuration Management Tools を真っ先に思い浮かべる人が多いだろう。


だが現在では、Configuration Management 以外の領域への Infrastructure as Code
の適用が進んでおり、その領域もいくつかに分類することができる。これについては後に詳しく触れる。



----

## Infrastructure as Code を支えるツールやサービス

----

## Infrastructure as Code のプラクティス

----

## Infrastructure as Code に関するイベントやります


http://kief.com/automated-server-management-lifecycle.html

https://www.thoughtworks.com/insights/blog/infrastructure-code-iron-age-cloud-age
https://www.thoughtworks.com/insights/blog/infrastructure-code-automation-fear-spiral

本当のプラクティスを適用できるのか？
→ CI で見ると、時間がかかりすぎている




http://www.iu.hio.no/~mark/papers/cfengine_history.pdf

https://www.domenkozar.com/2014/03/11/why-puppet-chef-ansible-arent-good-enough-and-we-can-do-better/


https://www.domenkozar.com/2014/03/11/why-puppet-chef-ansible-arent-good-enough-and-we-can-do-better/

http://nixos.org/~eelco/pubs/nixos-jfp-final.pdf

http://nixos.org/

http://www.ryuzee.com/contents/blog/7085


Confugiration drift
Snowflake servers
Jenga infrastructure
Automation fear
The automation fear spiral
erosion

Twelve-factor app


* Dynamic Infrastructure
  * IaaS
  * AWS, OpenStack
  * VMWare vSpere
  * Cobbler or Foreman or FAI
* Infrastructure Orchestration
  * Terraform, CloudFormation
  * Configuration registry(consul, etcd, zookeeper)
* Server Configuration
  * Puppet, Chef, Ansible, Itamae
* Infrastructure Service


https://coreos.com/blog/introducing-ignition.html
