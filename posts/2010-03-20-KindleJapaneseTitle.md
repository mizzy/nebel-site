---
layout: post
title: KindleJapaneseTitle
date: 2010-03-20 19:04:33 +0900
---


Kindle Store で樋口一葉、芥川龍之介、夏目漱石らの日本語書籍が出てたのは以前から知っていたのですが、最近 [Amazon Kindleで日本語のコンテンツが読める！ 日本語電子書籍「想隆社文庫」創刊！一般向けおよび図書館向けに提供を開始](http://www.atpress.ne.jp/view/14142) といったプレスリリースが出てたので、どんなものか確認するために、実際に購入してみました。

結論から言うと、「6インチ Kindle 上では薄くて読みづらい。お金出して買う価値なし。今出てるタイトルなら、青空キンドルを使っとけ。」といったところでしょうか。

----

以前から出てた日本語タイトルのスクリーンショット。

[[Image(http://mizzy.org/img/kindle/kokoro.gif, 25%)]]

----

最近プレスリリースが出ていた、「これまでの電子書籍と異なり、従来の紙の本好きが違和感なく読めることを重視。書籍DTPを行う職人による組版を採用し、版面の美しさを追求しました。」と謳われているもののスクリーンショット。

[[Image(http://mizzy.org/img/kindle/sumidagawa.gif, 25%)]]

----

青空キンドルのスクリーンショット。

[[Image(http://mizzy.org/img/kindle/bottyan02.gif, 25%)]]

----

自分でスキャンしたもののスクリーンショット。

[[Image(http://mizzy.org/img/kindle/mahjong03.gif, 25%)]]

----

こうして比較してみると、青空キンドルが神すぎる。また、自分でスキャンしたものは文字サイズが小さいけど、濃さ的には上2つよりも読みやすい。実際、Kindle実機上だと上2つは、スクリーンショットのものよりも更に薄くて読みづらい。

どうやら上2つの Kindle Store で手に入る日本語タイトルは、すべて画像データの模様。（ちなみに、Kindle の azw フォーマットは、Mobipocket フォーマットをベースにしていて、文字データは HTML で記述する。）フォントの関係で、画像になっちゃうのはしかたないのかもしれないけど、文字サイズ変更もできないし、テキスト読み上げもできないし、その上読みづらい、といった感じで、Kindle 版を購入するメリットがまったくない。

発売されている（またはこれから発売予定の）タイトルも、すべて青空文庫で手に入るタイトルばかりのようなので、現段階なら青空キンドルを利用するのがベスト。

DX の方だともう少し読みやすかったりするのかもしれないけど、小説の類はDXで読むメリットはあまりないと思う。

----

ちなみに、実際にファイルを展開してみたら、やはり全部画像ファイルでした。ファイルの展開は Perl の EBook::Tools モジュールを利用すると簡単にできます。

	
	$ perl -MEBook::Tools::Unpack \
	 -e 'EBook::Tools::Unpack->new(
	 file => "Natsume Soseki Story Selection v-asin_B00300H6UY-type_EBOK-v_0.azw"
	 )->unpack'
	