---
layout: post
title: NagiosBook
date: 2011-04-05 01:03:02 +0900
---


#!html
	<a href="http://www.amazon.co.jp/dp/4774145823"><img src="http://image.gihyo.co.jp/assets/images/cover/2011/9784774145822.jpg" /></a>
	

技術評論社様よりご献本頂きました。

タイトルの通り、監視ソフトウェア [Nagios](http://www.nagios.org/) のリファレンス本です。日本語の Nagios に関する書籍としては、[Nagios 2.0オープンソースではじめるシステム&ネットワーク監視](http://www.amazon.co.jp/dp/4839920168) につづいて2冊目ですかね。（著者は同じ方のようです。）

本書の目次は以下のようになっています。

* 第1章 Nagiosクイックスタート
* 第2章 Nagios標準プラグイン
* 第3章 メイン設定ファイル
* 第4章 CGI設定ファイル
* 第5章 オブジェクト設定ファイル
* Appendix A Nagiosと周辺ツールの導入
* Appendix B リソース設定ファイルとNagios標準マクロの概要


同じ Software Design plus シリーズの監視ソフトウェアを扱った書籍である [wiki:ZabbixBook Zabbix統合監視「実践」入門 〜障害通知、傾向分析、可視化による省力運用〜] は、タイトルの通り入門書という感じで、はじめて Zabbix に触れる人を対象に、インストールから設定まで丁寧に書かれてるのに対し、こちらは「リファレンス」の名の通り、どちらかというと既に Nagios を利用している人向けのリファレンスとなっています。

第1章ではざっくりと Nagios とは何かの説明がされてますが、第2章以降はすべてプラグインや設定ファイル、設定項目ひとつひとつに関する説明がひたすら続いていきます。（Appendix A でインストールに関する説明があります。）

実際にサービス運用監視で Nagios を利用している人が手元に置いておいて、あれ、このプラグインのパラメータって何をどういう風に渡すんだっけ、とか、この設定項目いじると何がどうなるんだっけ、などといった時にパラパラめくったりするのに良さそうですね。

とは言うものの、[ペパボ](http://www.paperboy.co.jp/) では Nagios 使ってるんですが、自分はサービスの運用監視には直接関わっていないため、Nagios にほとんど触れることがないんで、宝の持ち腐れですね。（監視シフトに合わせてウェブ上で timeperiods.cfg を設定するようなツールを作ったことがあるぐらいですね。） 良い機会なので、自宅サーバに Nagios 導入してみようかな。

あとこの本とは関係ないですが、Nagios といえば度々話題になるのは、どう発音するのか、ですよね。FAQ へのリンク貼っておきます。

* [How do you pronounce Nagios?](http://support.nagios.com/knowledgebase/faqs/index.php?option=com_content&view=article&id=52&catid=35&faq_id=3&expand=false&showdesc=true)
* [Nagios pronunciation](http://community.nagios.org/2007/02/20/nagios-pronunciation/)

2番目のエントリには以前音声ファイルがあった気がするんですが、今はないみたいですね。（たしか「*ナ*ギオス」と発音してました。「ナ」にアクセント。）
