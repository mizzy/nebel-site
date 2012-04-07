---
layout: post
title: KlabAndFuncAndPunc
date: 2008-03-30 21:28:20 +0900
---


[KLab 勉強会 #4](http://dsas.blog.klab.org/archives/51199866.html) で、[Func](https://fedorahosted.org/func/) についてしゃべってきました。その時の様子は [Ustream](http://www.ustream.tv/channel/KLab) でご覧いただけます。また資料は後日 [DSAS 開発者の部屋](http://dsas.blog.klab.org)にアップされると思います。

スピーカのために壇上に水が用意されていることはよくあると思いますが、今回は僕のためにドクターペッパーが用意されているというスペシャルな待遇に感激しました。

で、Func についてしゃべった中で、いくつかいけてない点をあげたのですが、特に RedHat 系 Linux にしか対応してない、というところに不満もあり、また、モジュールを Perl で書きたいという思いもあり、じゃあ Perl で実装しちゃえ、ってことで、[Punc - Perl Unified Network Controller](http://coderepos.org/share/wiki/Punc) なるものをつくりはじめました。

今のところプロトタイプでしかないため、まだまだ完成には程遠いですが、RedHat 系 Linux 上でサービスの起動状態を確認する、ということができるまでにはなっています。他の OS 用のモジュールを追加すれば、自動で判別して適切なモジュールを選択してくれる機能も実装しています。

YAPC::Asia 2008 でお話しする予定の [システム管理フレームワークのアーキテクチャと Perl による実装](http://conferences.yapcasia.org/ya2008/talk/973) では、この Punc について詳しく解説する予定です。
