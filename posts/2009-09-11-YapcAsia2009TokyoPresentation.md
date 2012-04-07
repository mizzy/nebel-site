---
layout: post
title: YapcAsia2009TokyoPresentation
date: 2009-09-11 00:21:28 +0900
---


ひとつ目は [ペパボでの Perl のつかいかた](http://conferences.yapcasia.org/ya2009/talk/2166) 。[id:hiboma](http://d.hatena.ne.jp/hiboma/) と一緒にプレゼンしました。[お兄さん](http://d.hatena.ne.jp/naoya/)、ネタに使わせてもらってすみません＆ありがとうございました。後半のロリポの話は、二人で休日も返上してがっつり取り組んだプロジェクトだったので、ぜひ二人で発表したい、と思い、一緒にやらせてもらいました。資料の最新版は id:hiboma が持ってるので、そのうちアップしてくれると思います。

ふたつ目は [Danga::Socketの非同期処理の仕組みとPerlbalで非同期処理するプラグインを書く方法](http://conferences.yapcasia.org/ya2009/talk/2220) 。[英語版資料](http://www.slideshare.net/mizzy/how-dangasocket-handles-asynchronous-processing-and-how-to-write-asynchronous-perlbal-plugins) と [日本語版資料](http://www.slideshare.net/mizzy/dangasocketperlbal) を slideshare にアップしています。

また、プラグインのコードは、プレゼン中は概要しか紹介できなかったので、実際に動くサンプルを [github にアップ](http://github.com/mizzy/perlbal-async-plugin-example/tree/master)しています。Perlbal::ClientProxy のパッチと設定ファイルも合わせて置いてあります。

ただ、プレゼンした手法は、以下の点でとても実用的とは言えません。

* 本体に手を入れなければいけない
* 特定の hook にしか対応してない
* 同じフックで複数の非同期処理プラグインを動かすことができない

本体に手を入れるのはしかたないとして、特定のフックに依存せずに、同じフックで複数の非同期処理プラグインを動かせるようするにはどうすればいいのか、今のところノーアイデアです。これがすっきりできるように実装できれば、ぜひパッチを送りたいところなのですが、今のところ必要に駆られてないので、たぶんやらないと思います。
