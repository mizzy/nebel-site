---
title: serverspec でホスト固有の属性値を扱う方法
date: 2013-05-12 22:05:26 +0900
---

**注意！ ここで解説する方法は v0.3.0 から利用できます。**


[Provisioning Frameworks Casual Talks vol.1 に行ってきた #pfcasual - TAKUMI SAKAMOTO'S BLOG](http://blog.takus.me/2013/05/12/provisioning-frameworks-casual-talks-001/) で触れられている attributes 周りについて、この辺は必要になるだろうなー、と前から思ってはいたので、それを実現するための極々簡単な仕組みを [試験的に実装してみた](https://github.com/mizzy/serverspec/pull/98) 。

これは単に ``attr_set`` と ``attr`` という2つのヘルパーメソッドを使えるようにしただけのものなんだけど、以下のような感じで使える。

今回は例として、ホスト毎に MySQL の server-id が外部ファイルで定義されていて、各サーバの /etc/my.cnf で正しく server-id が設定されているかをテストする、という状況を想定する。

属性値の定義は、今回は YAML ファイルで行うので、以下のような YAML ファイルを用意する。

{% gist 5563530 %}

次に、[serverspec のテストをホスト間で共有する方法](/blog/2013/05/12/1/) と似たような感じで、YAML で定義されたロールに応じて適切なテストを行うような ``Rakefile`` を書く。

{% gist 5563531 %}

そして ``spec_helper.rb`` を以下のように書く。

{% gist 5563533 %}

``attr_set attributes[c.host]`` で属性値のセットを行っている。

最後に、属性値を参照して ``attr[:server_id]`` が ``/etc/my.cnf`` で定義されているかどうかをテストする spec を書く。

{% gist 5563537 %}

仕組みは単純なので、``YAML.load_file`` している部分を好きなように変えれば、自身の環境に合った使い方ができるでしょう。


