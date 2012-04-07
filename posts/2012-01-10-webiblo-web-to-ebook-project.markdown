---
layout: post
title: "Webiblo - web to ebook project"
date: 2012-01-10 19:02
comments: true
categories: 
---

久々に日本語で書きます。（後で英語でも書く。）

[Web-to-mobi](/blog/2012/01/09/web-to-mobi-a-script-for-converting-web-sites-to-mobipocket-format/) を焼き直して、[Webiblo](https://github.com/mizzy/webiblo) というプロジェクトを立ち上げてみました。

基本的には GitHub の README に書いてある通りなんですが、ウェブサイトについて記述された JSON を喰わせることによって、Kindle で読める mobipocket フォーマットの電子書籍データを作ろう、また、様々なサイト対応の JSON データを集めたい、というのがこのプロジェクトの趣旨です。

現在は、

    $ webiblo.pl http://mizzy.org/webiblo/data/Getting_Real.json

といった感じで、JSON が記述された URL を指定するか、

    $ cat data.json | webiblo.pl

といった形で JSON を標準入力から渡してやれば、与えられたデータにしたがって、mobipocket 形式のデータを生成します。（[KindleGen](http://www.amazon.com/gp/feature.html?docId=1000234621) が必要です。）

JSON データは以下のようになっています。

    {
        "title"       : "Structure and Interpretation of Computer Programs",
        "authors"     : [
            "Harold Abelson",
            "Gerald Jay Sussman",
            "Julie Sussman"
        ],
        "cover_image"   : "http://mitpress.mit.edu/sicp/full-text/book/cover.jpg",
        "content_xpath" : "//div[@class=\"content\"]", # Optional
        "exclude_xpath" : "//div[@class=\"navigation\"]", # Optional
        "chapters" : [
            {
                "title" : "Foreword",
                "uri"   : "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-5.html#%_chap_Temp_2"
            },
            {
                "title" : "1  Building Abstractions with Procedures",
                "uri"  : "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-9.html#%_chap_1",
                "sections" : [
                    "title" : "1.1  The Elements of Programming",
                    "uri"   : "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-10.html#%_sec_1.1"
                    "subsections" : [
                        {
                            "title" : "1.1.1  Expressions",
                            "uri"   : "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-10.html#%_sec_1.1.1"
                        },
                    ]
                ]
            }
        ]
    }

ざっくり構造としては、以下のようになっています。

 * 書籍データ
   * 本のタイトル
   * 著者
   * 表紙画像
   * コンテンツとして抜き出す部分の XPath（オプショナル）
   * コンテンツから除外したい部分の XPath（オプショナル）
   * 章
     * 章タイトル
     * 章ページの URI
     * セクション
       * セクションタイトル
       * セクションページの URI
       * サブセクション
         * サブセクションタイトル
         * サブセクションページの URI


JSON データは現在のところ、[Getting Real](http://gettingreal.37signals.com/toc.php) 用のものと [SICP](http://mitpress.mit.edu/sicp/full-text/book/book.html) 用のものを [こちら](http://mizzy.org/webiblo/) で公開しています。

JSON データは GitHub リポジトリの gh-pages ブランチに置いてあるので、独自の JSON データを作成した方は pull request 送ってもらえるとうれしいです。

webiblo で生成したデータを Kindle Previewer で見ると、こういった感じになります。

{% img /images/2012/01/sicp_cover.png 250 SICP Cover %}
{% img /images/2012/01/sicp_toc.png 250 SICP TOC %}
{% img /images/2012/01/sicp_content.png 250 SICP Content %}

元々は、単に Getting Real 英語版のデータを mobipocket 形式に変換したかっただけなんですが、Facebook での otsune さんのアドバイスにより、こういった形で、書籍固有のデータを分離する形でつくってみました。

また、[@hotchpotch](http://twitter.com/hotchpotch) さんから、[Autopagerize の SITEINFO を活用したアプローチ](http://subtech.g.hatena.ne.jp/motemen/20110915/1316088362) もあるよ、と教えて頂き、うおー、これはエレガントだ、と思ったんですが、こちらは目次ページを作成する機能がなさそうだったので、とりあえず当初の JSON を利用するというコンセプトのまま開発を進めました。

今後の TODO としては、以下のものを考えてます。

 * EPUB3 など、mobipocket 以外のフォーマット対応
 * CLI から JSON カタログを検索して、簡単にデータ生成できるようにする
