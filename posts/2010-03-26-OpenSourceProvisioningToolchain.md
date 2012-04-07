---
layout: post
title: OpenSourceProvisioningToolchain
date: 2010-03-26 00:40:19 +0900
---


DevOps に関する理解を深めるために、資料にあたってまとめてみるシリーズ。

今回は [Velocity Online Conference - March 17, 2010](http://en.oreilly.com/velocity-mar2010) でのプレゼン [Provisioning Toolchain](http://en.oreilly.com/velocity-mar2010/public/schedule/detail/14180) から。スライドのタイトルは「OpenSource Provisioning Toolchain」となっている。

[wiki:DevOps 昨日のエントリ]でいうと、「インフラの自動化」や「ワンステップビルド＆デプロイ」に関連する話。

Toolchain というのは何らかの目的を達成するためのソフトウェアの集まり、ってことなので、Provisioning Toolchain は、プロビジョニングを行うためのソフトウェアの集まり、ってことですね。つまり OpenSource Provisioning Toolchain は、プロビジョニングを行うためのオープンソースソフトウェアの集まり、ということ。

ここでわざわざ Toolchain といってるのは、ひとつの大きなソフトウェアで全部やるんじゃなくて、小さなソフトウェアを組み合わせることで、プロビジョニング全体をカバーしよう、という考えから。

小さなツールを組み合わせることによるメリットを、UNIX哲学的な話と絡めて説明してるけど、この辺はよくある話なので省略。

また、なぜこのような Toolchain が必要なのか、って話を、クラウドや仮想化の波が押し寄せてきて DevOps 問題が発生する云々、的なスライドがあるんだけど、それ以上の詳しい説明が特にないのでこれも省略。

個人的に参考になったのは、プロビジョニングを3つの領域にわけて、それぞれの領域に対応するオープンソースソフトウェアを挙げているところ。（オープンソースじゃないモノも混じってるけど。）

3つの領域とは以下の通り。

* Orchestration
   * Application Service Deployment
* Configuration
   * System Configuration
* Bootstrapping
   * OS install
   * Cloud or VM Image Launch

下の方がプロビジョニングの初期段階で、上に行くほどレイヤーが上がるイメージ。

で、それぞれに対応するソフトウェアは以下の通り。

* Orchestration
   * [Capistrano](http://www.capify.org/index.php/Capistrano)
   * [ControlTier](http://controltier.org/wiki/Main_Page)
   * [Fabric](http://docs.fabfile.org/)
   * [Func](https://fedorahosted.org/func/)
* Configuration
   * [BCFG](http://trac.mcs.anl.gov/projects/bcfg2)
   * [Cfengine](http://www.cfengine.org/)
   * [Chef](http://www.opscode.com/chef)
   * [Puppet](http://www.puppetlabs.com/)
   * [SmartFrog](http://wiki.smartfrog.org/wiki/display/sf/SmartFrog+Home)
* Bootstrapping
   * [AWS](http://aws.amazon.com/)
   * [Cobbler](https://fedorahosted.org/cobbler/)
   * [Eucalyptus](http://www.eucalyptus.com/)
   * [Jumpstart](http://en.wikipedia.org/wiki/Jumpstart_%28Solaris%29)
   * [Kickstart](http://fedoraproject.org/wiki/Anaconda/Kickstart)
   * [OpenNebula](http://www.opennebula.org/start)
   * [OpenQRM](http://www.openqrm.com/)
   * [VMWare](http://www.vmware.com/)

ペパボの場合だと、全部のサービスがそうというわけではないけど、Bootstrapping レイヤーで Cobbler、Configuration レイヤーで Puppet、Orchestration レイヤーで Capistrano(Webistrano) や Func、といった感じ。ここにないものだと、Orchestration レイヤーで Archer なんかも使ってる。

今日は手抜きだけどこれでお終い。これから [MAG](http://www.jp.playstation.com/scej/title/mag/) やるので。DLC第1弾トルーパーパックが配信されたしね。
