---
title: Developers Summit 2014 で「サーバプロビジョニングのこれまでとこれから」という発表を行いました
date: 2014-02-14 01:33:52 +0900
---

<div style="width: 65%">
<script async class="speakerdeck-embed" data-id="3fc5c5d07684013148646268bd6e389b" data-ratio="1.3333333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

内容自体は基本的に、[第5弾 週末ランサーズ](http://atnd.org/event/E0021065) にお邪魔した時に [お話した資料](https://speakerdeck.com/mizzy/future-of-server-provisioning) と同じなんですが、この時よりも時間が少し長かったので、多少内容を追加しているのと、当時自分の中でうまく整理できてなかったけど、今は多少クリアになった部分もあって、そういった内容を盛り込んだりしてみました。

 * [Togetter まとめ](http://togetter.com/li/628616)
 * [NAMIKAWA さんによるまとめ](http://d.hatena.ne.jp/rx7/20140213/p1)

一点お詫びしたいのは、登壇者に質問ができる Ask the Speaker というコーナーがあって、セッションが終わった後はそちらに移動、という段取りだったのですが、裏でやっていた [OSS コミッタ大集合](http://event.shoeisha.jp/devsumi/20140213/session/394/) の方でも登壇するために終了後すぐに E 会場に向かったため、Ask the Speaker コーナーに行けませんでした。もし質問するためにいらしてくださった方がいましたら、本当に申し訳ないです。

今回デブサミに登壇させて頂いた経緯については、会場で [@t_wada](http://twitter.com/t_wada) さんからも説明があったのですが、[Testing Casual Talks #1](http://atnd.org/events/40914) でご一緒させて頂いたり、[インフラ系技術の流れ](http://mizzy.org/blog/2013/10/29/1/) というブログエントリを読んでくださった @t_wada さんから直々に依頼があり、二つ返事で OK させて頂いた、という次第です。

お話したテーマのうちのひとつである「テスト駆動インフラ」は、Puppet を使い始めてから割とすぐに考えはじめて、[2007 年には「テスト駆動サーバ構築」という言葉を使ったり](http://d.hatena.ne.jp/dayflower/20070405/1175782564#c) してました。（当時はインフラという言葉が今のような使われ方をしていなかった。）

で、それを実現するための [Assurer](http://tokyo2007.yapcasia.org/sessions/2007/02/assurer_a_pluggable_server_tes.html) というツールを 2007 年につくって YAPC で発表したものの、実用には至らず頓挫した、という経緯があったりします。

それから実に6年もかかって serverspec が生まれたわけですが、テスト駆動インフラという言葉は割と認知されてきたのかな、という状況で、言葉尻をとらえて「インフラをテスト駆動？何それpgr」みたいな意見も見かける中、@t_wada さん直々の登壇依頼が来た、という事実は、テスト駆動開発の第一人者からテスト駆動インフラと serverspec が認められた、お墨付きを頂けた、ということであると（勝手に）受け止め、本当にうれしかったですね。

登壇の前後でも以下の様なお言葉を頂けて、こちらこそ登壇依頼を頂いて本当に良かったですし、感無量です。ありがとうございました。

<blockquote class="twitter-tweet" lang="en"><p>朝の舞台挨拶を終えました。そして mizzy さんの登壇を実現できただけで感無量なのだなぁ <a href="https://twitter.com/search?q=%23devsumiB&amp;src=hash">#devsumiB</a></p>&mdash; Takuto Wada (@t_wada) <a href="https://twitter.com/t_wada/statuses/433769588715577344">February 13, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p>mizzy さん (<a href="https://twitter.com/gosukenator">@gosukenator</a> さん) の話、インフラ技術のこれまでとこれからを語るスケールの大きい話だった。特に後半はワクワクしっぱなしだったな。登壇して頂けて本当に良かった。 <a href="https://twitter.com/search?q=%23devsumiB&amp;src=hash">#devsumiB</a></p>&mdash; Takuto Wada (@t_wada) <a href="https://twitter.com/t_wada/statuses/433781951523069952">February 13, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
