---
layout: post
title: Karesansui
date: 2010-01-26 00:10:07 +0900
---


[Karesansui](http://karesansui-project.info/) が [KVM に対応というニュース](http://builder.japan.zdnet.com/news/story/0,3800079086,20407326,00.htm) を見たので、試してみることにした。

[チュートリアル](http://karesansui-project.info/wiki/karesansui/Ja_tutorial) では OS インストールから解説されていてとても親切なんだけれど、うちの既存環境は CentOS 5.3 から 5.4 にアップグレードして KVM 環境を整えたせいか、いくつかはまったポイントが。

チュートリアルでは、kvm-qemu-img を削除しておけ、と書いてるんだけど、うちの環境では、以下の qemu と名のつくパッケージをすべて削除する必要があった。

* qemu
* qemu-system-sh4
* qemu-system-ppc
* qemu-system-arm
* qemu-system-x86
* qemu-system-cris
* qemu-system-sparc
* qemu-system-mips
* qemu-system-m68k
* qemu-user
* qemu-common
* qemu-img  

また、PyXML も別途インストールが必要だった。

あとはチュートリアルの通りに、karesansui-install を実行して、画面に従ってインストール。設定も特にいらず、簡単。

まだインストールしてブラウザでアクセスしただけなんだけど、気になった点がいくつか。

* 既にある KVM ゲストが一覧に表示されない
   * おそらくどこか(/var/opt/karesansui/karesansui.db あたり？)にゲスト情報を持つことになってるんだろうけど、libvirt あたりつかって既存のゲストを自動認識、とかしてくれるといいな
* 同じ理由で、Cobbler + Koan でゲスト作成しても認識してくれなさそう
* リモートホストのゲスト管理
   * [複数ホスト構成にするには？](http://karesansui-project.info/wiki/karesansui/Ja_howto_multi_host) を見ると、すべてのホストに Karesansui をインストールすることで、一カ所でまとめて管理できるみたいだけど、Karesansui 入れるのは一カ所だけで、あとは libvirtd さえ動いてれば OK、とかできるといいなー。おそらく事情があってこうなってないんでしょうけど。

まあ、オープンソースなんでグダグダ言ってないでパッチ書け、ってとこですかね。とりあえず動作を追ってみるところからはじめてみます。
