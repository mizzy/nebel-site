---
layout: post
title: XenSummitTokyo2008Libvirt
date: 2008-11-20 16:33:16 +0900
---


[Xen Summit 2008 Tokyo](http://software.fujitsu.com/jp/linux/event/xensummit2008-tokyo/) で発表した、「Operating Xen domains through LL(Perl/Python) with libvirt」の資料を [SlideShare にアップしました](http://www.slideshare.net/mizzy/xen-summit-2008-tokyo-operating-xen-domains-through-llperlpython-with-libvirt-presentation/)。

[libvirt](http://libvirt.org/) という仮想化システムを操作するためのライブラリがあるんですが、それをつかって Perl/Python で Xen を管理するプログラムを書く、ということにフォーカスした内容です。

Perl/Python での libvirt プログラミングだけではなく、libvirt そのものの概要やアーキテクチャ、[Avahi](http://avahi.org/) という mDNS 実装との連携で、libvirtd が動いているホストを自動で発見する Perl コードのサンプル、Func の virt モジュールは裏で libvirt を使ってる、といったような内容が含まれています。

Xen Summit では、フリードリンクとしてドクターペッパーが用意されていました。しかも、スタッフの方が僕がドクターペッパー好きだということを知っていて用意してくださった、ということで、あまりの VIP 待遇に感激しました。[daisikip さん](http://daiskip.com/) に言われたのですが、そのうちドクターペッパーの CM 出演依頼が来るんじゃないかと思います。