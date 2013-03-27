---
title: Ukigumo と serverspec で Puppet の継続的インテグレーション
date: 2013-03-27 21:38:39 +0900
---

[tokuhirom](http://blog.64p.org/) さんにより開発されている [Ukigumo](http://ukigumo.github.com/ukigumo/) を利用して、Puppet の CI 環境を構築してみた。やってることは以下の通り。

 * Puppet マニフェストを Git リポジトリで管理
 * [Ukigumo Server](http://ukigumo.github.com/Ukigumo-Server/) を立てる
 * [puppet-lxc-test-box](/blog/2013/03/22/1/) で Puppet マニフェストを流し込むシステムコンテナを必要なロールの分だけ用意
 * [自前の Ukigumo クライアントスクリプト](https://gist.github.com/mizzy/5252543) を cron で定期的に走らせ以下を実行
   * Puppet マニフェストリポジトリの master ブランチが更新されていたら、git pull して Puppet マニフェストをシステムコンテナに適用し、適用結果を Ukigumo サーバに投げる
   * [serverspec](/blog/2013/03/24/3/) によるテストをシステムコンテナに対して実行し、結果を Ukigumo サーバに投げる

Ukigumo のトップ画面はこんな感じ。最新の結果一覧が表示されている。

{% img /images/2013/03/ukigumo-top.jpg %}

Puppet マニフェストの適用結果の詳細はこんな感じ。

{% img /images/2013/03/ukigumo-puppet.jpg %}

serverspec によるテスト結果の詳細はこんな感じ。

{% img /images/2013/03/ukigumo-serverspec.jpg %}

結果は [Ikachan](http://blog.yappo.jp/yappo/archives/000760.html) に投げて IRC で通知してる。

{% img /images/2013/03/ukigumo-irc.jpg %}

これで Puppet マニフェストをガリガリとリファクタリングするための準備が整った。

[puppet-lxc-test-box](/blog/2013/03/22/1/) や [serverspec](/blog/2013/03/24/3/) をつくったのは、こういうことがやりたかったから、ってなことを社内 IRC に書いたら、[#3分で常松](https://twitter.com/search/realtime?q=%233%E5%88%86%E3%81%A7%E5%B8%B8%E6%9D%BE&src=typd) くんを濡らすことに成功した。

<blockquote class="twitter-tweet"><p>「15:00 mizzy: 最近ブログに書いてたことは、すべてこれへの布石」のカッコイイ感はんぱなくて濡れる</p>&mdash; TSUNEMATSU Shinya (@tnmt) <a href="https://twitter.com/tnmt/status/316792813712977920">March 27, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Ukigumo もとてもシンプルでいいですね。