---
title: 自分のプロダクトを海外でも認知してもらうには
date: 2013-09-21 21:59:02 +0900
---

ブログを書くまでが YAPC、ってことなので書きます。

YAPC 懇親会で [@hirose31](https://twitter.com/hirose31) さんと「日本人の作ったプロダクトでとても優れていて日本では知名度抜群なのに、海外では全然知られてない、みたいの割とあるけど、どうやったら serverspec みたいに海外でも認知されるようになるんですかね」みたいな話をしました。

serverspec の海外での知名度、といっても、日本での知名度と比較すればまだまだ全然、という感じですが、たまに海外の方の tweet を見かけたり、[Serverspec the New Best Way to Learn and Audit Your Infrastructure](http://jjasghar.github.io/blog/2013/07/12/serverspec-the-new-best-way-to-learn-and-audit-your-infrastructure/) というブログエントリを書いてくださった方がいたり、[Food Fight という Podcast で取り上げられたり](http://foodfightshow.org/2013/05/testing-in-practice.html)、[O'Reilly の Test-Driven Infrastructure with Chef 2nd Edition](http://shop.oreilly.com/product/0636920030973.do) で取り上げられたり、[Puppet Labs の中の人が Vagrant 対応パッチを送ってくれたり](https://github.com/serverspec/serverspec/pull/128)、[Opscode の中の人が issue open してくれたり](https://github.com/serverspec/serverspec/issues/239)、といった感じで、そこそこ海外の方にも知られる存在になっていて、そうなるように意識してやったことがいくつかあるので、それについて簡単に整理してみます。

## 英語でドキュメントを書く

これは当たり前、というか、大前提なので、特に説明の必要はないですね。

## メジャーなキーワードを散りばめる

[GitHub の description](https://github.com/serverspec/serverspec ) や [serverspec.org](http://serverspec.org/) には serverspec の説明として **"RSpec tests for your servers configured by Puppet, Chef or anything else"** といった言葉があるのですが、**"Puppet"** や **"Chef"** といったワードがあるために、辿り着いて興味を持った人が多いのではないかと思います。特に、Puppet Labs や Opscode の中の人は、Puppet や Chef でエゴサーチしてるでしょうし、そういった方々にリーチして、tweet してもらったりすることで、認知度が高まったのではないかと。

## ぱっと見てどんなものかわかりやすくする

検索等で辿り着いたとしても、ぱっと見て何をするものなのかがわからないと、すぐに興味を失って二度と訪れてくれなくなるので、[serverspec.org](http://serverspec.org/) のトップページは、ざっと見ただけで何をするものなのかがすぐに理解できる、ということ意識しています。

## 名前が覚えやすい

**serverspec = server + rspec** ととても安直ですが、それが故に覚えやすく、名前から何をするものなのかが連想しやすいし、tweet 等する時に書きやすいので、それも良かったのではないかと。

----

とまあこんな感じで、そんな大したことやってないですが、他にも要因は色々あるんでしょうね。例えば、Test-Driven Infrastructure という考え方が浸透してきたけど、serverspec ほどシンプルで敷居の低いツールが他になかった、とか、いわゆる開発者と呼ばれる人たちに Puppet や Chef が浸透してきて、そういった人たちに「サーバのテストを RSpec でやる」というコンセプトが響いた、とか、時代の流れ的なものにうまく嵌まったのかなー、と。

----

あと、この話は、serverspec のような、技術者向けのツールとかライブラリにはある程度あてはまるでしょうけど、そうじゃないものだと、言語や文化の壁が大きくて、こうはいかないでしょうね。

----

というわけで、ブログ書くまでが YAPC と言っておきながら、YAPC 全然関係ないエントリをお送りしました。
