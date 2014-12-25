---
title: 「Serverspec」という本が出ます
date: 2014-12-25 10:00:00 +0900
---

ここ半年ほど取り組んでいた Serverspec に関する本が出ます。2015年1月17日発売予定です。

<a href="http://www.oreilly.co.jp/books/9784873117096/"><img src="http://www.oreilly.co.jp/books/images/picture_large978-4-87311-709-6.jpeg" style="width: 30%;" /></a>

[O'Reilly Japan - Serverspec](http://www.oreilly.co.jp/books/9784873117096/)

[Amazon.co.jp： Serverspec: 宮下 剛輔: 本](http://www.amazon.co.jp/dp/4873117097)

どんな内容か、というのは、サイトの紹介文や目次を見ればわかるので、ここでは、なぜこの鳥が表紙に選ばれたのか、といったことでも書こうかな、と思ったんですが、こういうのは明かさない方がおもしろいので、やっぱり書かないことにします。おそらく、何という名前の鳥なのかすらわからない方が大半かと思いますが、あえて伏せておきます。名前や生態は最後のページに載っていますので、知りたい方は買うなり、店頭で確認するなりしてみてください（妻が Facebook に名前を書いちゃってるけど）。


本書は、開発者である自分にしか書けないことをできる限り盛り込み、自分以外の人でも書けるようなことはなるべく省く、というスタンスで書いています。

したがって、Serverspec と密接に関連する、Infrastructure as Code、テスト駆動インフラやインフラ CI、Puppet や Chef といったサーバ構成管理ツール、Ruby や RSpec、Vagrant などについては詳しく解説せずに、参考となるサイトや書籍等を紹介するのみにとどめています。

Serverspec 自身の使い方についても、[オフィシャルサイト](http://serverspec.org/) にあるのと同程度のことしか書いていないので、基本的な使い方を懇切丁寧に解説している、といったような内容を期待されている方は、本書内でも紹介している [サーバ/インフラ徹底攻略](http://gihyo.jp/book/2014/978-4-7741-6768-8) の [naoya](https://twitter.com/naoya_ito)  さんや自分の記事を読んで頂く方が良いです。

その代わり、開発に至る経緯や開発する上での哲学、動作仕様や内部のアーキテクチャ、ソースコードレベルでの拡張方法など、表から見ただけではわからないようなことをふんだんに盛り込んでいます。

Serverspec について詳しく解説するということは、必然的に [Specinfra](https://github.com/serverspec/specinfra) のことも詳しく解説することになるわけですが、ドキュメントがまったくない Specinfra についても、ソースコードレベルで詳しく解説していますので、Specinfra をベースに Serverspec や [Itamae](https://github.com/ryotarai/itamae) とは違う何かをつくってみたい、という方にもお勧めです。

Serverspec は「ひとつのことをうまくやれ」という UNIX 哲学に基づき、できる限りシンプルに保つようにしています。そのシンプルさの裏には、6年の歳月（Serverspec の前身となるツールは2007年につくっていた）、様々な思考、試行といったものがあります。そういった Serverspec の裏の部分に興味のある方は、ぜひ手にとってみてください。

本書の構成は以下の通りですので、購入するかどうかの検討材料にどうぞ。

> 1章はServerspecが生まれた背景や、Serverspecとはそもそも何か、その利用目的は、といった概要の説明、Serverspec開発における哲学など、Serverspecの概要を俯瞰した内容となっています。
> 
> 2章ではServerspecの基本的な使い方を通じて、Serverspecのエッセンスについて紹介しています。
> 
> 3章ではServerspecを実践で利用するにあたって必要となる知識やテクニックについて解説しています。
> 
> 4章ではソースコードを元に、Serverspecの内部や、拡張方法について詳しく解説しています。
> 
> 5章ではServerspecと組み合わせることで、より便利に活用できるツールを紹介しています。
> 
> 6章ではServerspecを使用していて問題に遭遇した場合に、調査すべきポイントについて解説しています。
> 
> 7章ではServerspecの今後について、筆者の考えを述べています。
> 
> 付録では、リファレンスとして活用するのに便利なリソースタイプ一覧、v2での変更点、Serverspecが強く依存しているSpecinfraというライブラリの、Serverspec以外の利用例、Windows OSのテスト方法を解説しています。

[naoya](https://twitter.com/naoya_ito) さんによる「まえがき」もありますよ。

それにしても、本を一冊書き上げるのって大変ですね。執筆のストレスのせいか、自家感作性皮膚炎を発症し、全身痒くて眠れない日が何日か続いたりして大変でした。

<blockquote class="twitter-tweet" lang="en"><p>全身痒くて眠れないので修羅の門 第弐門をKindleで買って読んでる。</p>&mdash; Gosuke Miyashita (@gosukenator) <a href="https://twitter.com/gosukenator/status/516652343245299713">September 29, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>


