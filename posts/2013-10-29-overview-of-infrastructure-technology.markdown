---
title: インフラ系技術の流れ
date: 2013-10-29 03:01:13 +0900
---

ここ最近のインフラ系技術の流れがおもしろいなー、と思ったので、Puppet が出た辺りぐらいから、振り返って整理してみる。殴り書きなので、後から修正したり書き加えたりするかも。特に後半の方は、あまり考えが整理できてない。

最近のウェブ界隈での「インフラ」という用語の使われ方には、色々異論もあるようだけど、ここではごく最近使われるようになってきた、OS からミドルウェアといったソフトウェアレイヤーを指す言葉してしてのインフラについて触れる。（英語圏でも同様の意味で使われているようなので、ある程度市民権を得たと言っても良さそうだし。）

## プロビジョニングレイヤー

まず、前提知識としてプロビジョングレイやーと自分が勝手に呼んでるものついて整理。

Chef や Puppet は「プロビジョニングフレームワーク」とも呼ばれているが、以下の議論をより厳密にするために、[Lee Thompson 氏による Velocity 2010 での Provisioning Toolchain というタイトルのプレゼン](http://en.oreilly.com/velocity-mar2010/public/schedule/detail/14180) に基づき、プロビジョニングを以下の3つのレイヤーにわけて考える。（イメージしやすいように、それぞれに該当するツールやサービスを当て込んでみた。）

 * Orchestration
   * Fabric, Capistrano, MCollective
 * Configuration
   * Puppet, Chef, AWS OpsWorks
 * Bootstrapping
   * Kickstart, Cobbler, OpenStack, AWS

下の方から見ていくと、Bootstrapping はいわゆる OS インストールにあたる領域。Configuration はミドルウェアレベルまでの設定、Orchestration はアプリケーションデプロイなどを行って、個別のシステムをひとつのサービスとして協調動作させる、といった感じか。

この分類では、Puppet や Chef は Configuration 領域に属するものであり、プロビジョニングフレームワークという呼び方は適切ではなく、Configuration Management Tool とでも呼ぶべきものであるが、まあそこは些末なことなのでどうでもいい。

また、これらは厳密に区別できるものでもない。たとえば、Kickstart ファイルの中で Puppet を呼び出すなんてこともできるし、Puppet をアプリケーションデプロイにも利用するはめになって辛い、といった話を聞いたことがあったり、Capistrano でミドルウェアのインストールや設定なんかをやる、なんて事例も聞いたことがある。

最近出てきた Ansible なんかも、Orchstration と Configuration の中間に位置するような存在に見える。


## Puppet 以前

ここから、ある程度時間の流れにそって、プロビジョニングにまつわる技術の流れを振り返ってみたい。といっても、項目毎に、時間軸がオーバーラップしてたり、前後してたりするので、あまり厳密ではない。

いわゆる「Configuration Management Tool」としては、Puppet より前は、CFEngine, LCFG, BCFG といったものがあったようだが、どれもきちんと触ったことがないので、この辺はあまりよく知らない。この中では CFEngine が一番有名か。

システム管理自動化の走りがこの辺のツールなのかな。

## Puppet

Puppet が出てきたのは 2006 年あたり。Infrastructure as Code の流れの最初のきっかけを作ったのが Puppet なんじゃないかと。

LISA '07 では [CFEngine や Puppet 等の開発者のパネルディスカッションが行われていた](https://www.usenix.org/conference/lisa-07/panel-configuration-tools-lcfg-cfengine-bcfg-and-puppet) 。


## AWS EC2

これも登場は Puppet と同じく 2006 年あたりだった気がする。

Puppet での Infrastructure as Code はインフラをコードで記述するという意味であり、EC2 での Infrastracture as Code は、インフラをコードで操作する、という意味合いになる。

こんな形で、Infrastructure as Code を意味づける2つの技術が、2006年あたりに登場してる。


## Chef

Chef が出てきたのは 2009 年ぐらいかな？Puppet をベースに、さらにインフラをプログラマブルに扱う、という思想を推し進めたツールが Chef だと思う。これが IaaS の台頭により、開発者がインフラを触る機会が多くなり、そういった人たちに受け入れられたのが、今の Chef 人気の背景にはあるんじゃないかと。


## テスト駆動インフラ

これはここ数年で出てきた言葉で、認知されてきたのはごく最近のような気もするし、まだまだ認知されてないような気もする。

概念自体は 2007 年ぐらいから実は考えていて、その当時はインフラという言葉は今のような使われ方をしていなかったので、[テスト駆動サーバ構築](http://mizzy.tumblr.com/post/46834223858) という呼び方をしていた。

これを考え始めたきっかけは Puppet を使い始めたことで、構築は自動化できたけど、その確認作業を従来通り、目視の手動チェックでやるのはいけてないな、と考えたから。で、[Assurer というツール](http://tokyo2007.yapcasia.org/sessions/2007/02/assurer_a_pluggable_server_tes.html) でこれを実現しようとしてたんだけど、いろいろ夢が膨らみ、詰め込みすぎてすごく複雑になったり、自分の技術力もなかったりで、使わないまま消え去った。

書籍としては 2011 年に [Test-Driven Infrastructure with Chef](http://shop.oreilly.com/product/0636920020042.do) が出ていて、最近 [これの第2版](http://shop.oreilly.com/product/0636920030973.do) が出た。with Chef とタイトルにあるように、この辺りは Chef とその周辺ツールが色々と充実してる印象。

でも、自分は Chef 使ってないし、特定の Configuration Management Tool に縛られるのってどうなんだろう、と思って、もっと汎用的にシンプルにインフラのテストをしたい、と思って開発したのが [serverspec](http://serverspec.org/) 。2007年から考えていたテスト駆動インフラが、6年かかってようやく実現できた。長かった。

上で書いたように、この辺りのツールは Chef まわりが充実してるものの、テスト駆動インフラという考え方は、いまいち認知されてなかったように感じる。（特に日本では。海外はよくわからない。）

それが serverspec が登場することによって、だいぶ認知されてきたんじゃないかと自画自賛してる。

## インフラCI

アプリケーション開発と同じように、テスト駆動したら次は CI だ、というのは自然な流れだと思う。serverspec もこれがやりたいがために開発した。

インフラCIについては、実は [@riywo くんが昨年ブログエントリを書いている](http://blog.riywo.com/2012/05/27/145310) 。彼は現状を把握し、先を見通し、やるべきことを考え、それを実現する技術力がある、希有なエンジニアだと思う。

ペパボではちいさなプロジェクトで、Docker + Puppet + serverspec + Jenkins でのインフラ CI を最近やりはじめたところ。

## Immutable Infrastructure

[Trash Your Servers and Burn Your Code: Immutable Infrastructure and Disposable Components - Chad Fowler](http://chadfowler.com/blog/2013/06/23/immutable-deployments/) というブログエントリで知った言葉。

おおざっぱに言うと、システムを変更する際に、既に動いているサーバに対して変更を加えるのではなく、新しく別にシステムを構築し、古いシステムと差し替える、ってなことをやる。

日本語での解説は [Immutable Infrastracture について - apatheia.info](http://apatheia.info/blog/2013/08/10/immutable-infrastructure/) にあるのでこちらを参照してください。

オンプレな環境でもできないことはないんだろうけど、EC2 みたいに仮想マシンをプログラマブルに扱え、作ったり破棄したりすることが容易にできる環境があるからこそのテクニック。

これができるようになると、Chef や Puppet が謳う冪等性ってのはどうでもよくなってくる。ひとつのシステムにマニフェストやレシピを何度も何度も適用することがなくなるから。なので、Chef や Puppet に変わって、Immutable Infrastructure に適した Configuration Management Tool が今後出てくると思う。よりシンプルで、実行順序がわかりやすく制御しやすいものが。

## Container Base Deployment

Immutable Infrastructure は EC2 のような、ハイパーバイザー型仮想マシンでの話が主流だと思われるが、今後はコンテナ型仮想マシンで同じようなことをやる、という話が増えてくると思う。

ハイパーバイザー型仮想マシンによる Immutable Infrastructure では、リモートの本番環境に仮想マシンをつくって、それと古い仮想マシンを差し替える形になるが、コンテナの場合には、ローカルでコンテナをつくって、それをまるっとリモートに送り込む形のデプロイになるのではないだろうか。

コンテナの持つポータビリティの高さによって、こういうことが実現できるようになると思う。これができると何がうれしいかというと、既にペパボの一部でもやっているような、Docker でコンテナを作成、Puppet マニフェストを流し込んで serverspec でテスト、をした後に、現在であればコンテナをそのまま破棄してるけど、破棄せずにそのまままるっと本番にデプロイ、なんてことができるようになるんじゃないか、と妄想してる。

もちろん、ハイパーバイザー型仮想マシンの場合でも、Packer のようにローカル（Vagrant VM等）とリモート（EC2インスタンス）を抽象化して同じように扱えるような仕組みはあるが、コンテナの場合には「同じように扱える」ではなく「まったく同じもの」になるので、ローカルでコンテナをつくって十分にテストし、それを本番にデプロイしても、同じようにちゃんと動くだろう、という安心感はより高いと言えそう。


## Docker

上のインフラ CI や Container Base Deployment の項には何の説明もなく Docker が出てきてるが、これについては [naoya さんのエントリ](http://d.hatena.ne.jp/naoya/20130620/1371729625) や 　[Rebuild: 14: DevOps with Docker, chef and serverspec (naoya, mizzy)](http://rebuild.fm/14/) を参照。


## Serf

最近出てきた Serf。現在の Puppet や Chef をメインとしたプロビジョニングにおいては、サーバ毎に微妙に異なる設定（ホスト名やIPアドレスにひもづいた設定）や、サーバの増減によって動的に変わるような設定（ロードバランサや Nagios の監視対象など）なんかも、Puppet や Chef で管理しているが、これは Immutable Infrastructure のようなやり方とはあまり相性がよくなさそう。

特に動的に変わるような設定は、プロビジョニングの中でも、Configuration ではなく Orchestration の範疇になるので、最初の分類にしたがうと、Puppet や Chef はあまり向いてない領域とも言える。

これを解決するための手段のひとつが Serf で、Puppet や Chef でやってしまっている Orchestration 領域の仕事を Serf の方に任せることによって、良い感じのプロビジョニングができそう。[Serf vs. Chef, Puppet, etc.](http://www.serfdom.io/intro/vs-chef-puppet.html) に書いてあることは、そういうことだと理解した。

とはいえ、Serf 自体はゴシップベースプロトコルによるクラスタリングとイベントプロパゲーションが主な仕事で、その上で Orchestration するような仕組みを自分で作らないといけなさそう、今のところは。

Serf の次はその辺を解決するようなプロダクトを Mitchell Hashimoto 氏は出してくるのかな。（または、Serf にはプラグインの仕組みがあるようなので、プラグインで解決するのかもしれない。）
