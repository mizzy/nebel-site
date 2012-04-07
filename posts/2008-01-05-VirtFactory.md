---
layout: post
title: VirtFactory
date: 2008-01-05 20:17:06 +0900
---


[Cobbler](http://trac.mizzy.org/public/wiki/Cobbler) や [Koan](http://trac.mizzy.org/public/wiki/Koan) について触れたところで、次は [Virt-Factory](http://virt-factory.et.redhat.com/) です。

[Yappo さんが Xen 環境で Cobbler/Koan が動くことを検証してくださった](http://blog.yappo.jp/yappo/archives/000555.html)ので、心置きなく Virt-Factory の紹介ができます。こちらの身勝手なお願いに応じてくれた Yappo さん、ありがとうございます。

Virt-Factory は、大量の仮想サーバの管理を楽に行うためのツールで、Cobbler/Koan + Puppet + これらをラップするサーバ/クライアントデーモンとコマンドラインツール + Web UI + XMLRPC API、といった感じです。具体的には、以下のような感じ。

* Cobbler/Koan、Puppet の統合
   * Cobbler による PXE ブート + ネットワークインストール環境の構築。単に Cobbler を利用する場合とは違い、キックスタートファイルに、Virt-Factory に必要なパッケージのインストールや、インストール後に必要な処理の実行を含めてくれる。
   * Koan によるホスト OS や Xen/QEMU ゲスト OS のコマンド一発インストール。Koan を使う場合は、ホスト OS 上で実行する必要があるが、Virt-Factory を使うと中央のサーバからリモートで実行できる。
   * リモートのホスト OS 上にある仮想サーバの状況を、中央のサーバで一元管理できる。
   * Cobbler でのキックスタートファイル作成時に、Puppet パッケージのインストール処理を含めてくれたり、プロファイル属性として Puppet クラスを指定できたりとか。おそらく Puppet サーバのノード管理とも連携するんじゃないだろうか。（ここはまだちゃんと検証できてない。）
* Web UI でプロファイルやシステムの登録、管理などができる
* Web UI やコマンドラインツールは XMLRPC API と連携してる

とてもよさげなツールではあるのですが、色んなツールを統合してるだけあって、できることが多すぎてわけがわからないし、[本家サイトのインストール/セットアップドキュメント](http://virt-factory.et.redhat.com/vf-install-setup.php)の通りにやっても動かないし、ドキュメントも不十分で、これから触ってみようと思う方は苦労するかと思いますので、インストール手順から使い方まで、自分が理解できた範囲で、今後数回にわけてご紹介していこうと思います。

ただしプロダクトとしてはまだ発展途上という感じで、すぐに実践投入できるものではなさそうです。

~~とりあえず次回は Virt-Factory サーバのインストールと設定について解説予定です。~~[解説をアップしました](http://trac.mizzy.org/public/wiki/VirtFactoryServerSetup)。
