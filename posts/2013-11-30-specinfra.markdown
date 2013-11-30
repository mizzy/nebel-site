---
title: specinfra という serverspec/configspec に共通する処理を抜き出した gem をつくった
date: 2013-11-30 23:34:48 +0900
---

<blockquote class="twitter-tweet" lang="en"><p>The backend of serverspec/configspec might have to be extracted to a gem to accommodate people&#39;s preferences to abstraction level.</p>&mdash; kentaro (@kentaro) <a href="https://twitter.com/kentaro/statuses/405342692856451072">November 26, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

とあんちぽさんからごもっともな指摘をいただいたし、実際に [configspec](http://mizzy.org/blog/2013/11/25/1/) を書いてて、ほとんどが serverspec からのコピペで、今後開発をつづけるのであれば、共通部分を抜き出した gem をつくるべきだな、と思ったので、[specinfra](http://github.com/mizzy/specinfra) という gem をつくった。

specinfra で抜き出した処理は以下の部分。

* SSH, ローカル、WinRM などの実行形式を抽象化している backend と呼んでいるレイヤー
* OS を自動判別し、OS に適したコマンドを返す commands と呼んでいるレイヤー
* properties, configuration といったヘルパーメソッド

こんな感じで、実行形式の違いや OS の違いを吸収してくれるレイヤーとして specinfra を利用し、serverspec や configspec では、RSpec のマッチャに応じた具体的なコマンドを定義していくだけ、といった感じにした。

serverspec v0.12.0 や configspec v0.0.6 からは specinfra ベースになってる。serverspec は従来の spec_helper の書き方でも問題なく動くようにしてあるし、CI でヘビーに使ってる環境で問題なかったのでたぶん大丈夫だけど、何か問題とかあったらお知らせください。


specinfra を使うと、serverspec や configspec のような、RSpec でテスト書いたら裏で何かコマンドが実行される、みたいなものが比較的簡単につくれるはず。（つくりたい人が他にいるかどうか知らんけど。）