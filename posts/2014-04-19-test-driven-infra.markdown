---
title: WEB+DB PRESS Vol.80 に「実践 テスト駆動インフラ＆CI」という特集記事を書いた
date: 2014-04-19 23:35:00 +0900
---
最初に書いておくと、発売は4/24(木)です。（こういうエントリを見て、お、もう出たのか、と思って書店に行ったらまだだった、みたいな経験よくあるのであらかじめ。）

<a href="http://gihyo.jp/magazine/wdpress/archive/2014/vol80"><img src="http://image.gihyo.co.jp/assets/images/cover/2014/thumb/TH160_9784774163987.jpg" /></a>

Software Design 誌では何度か書かせてもらっていたのですが、WEB+DB PRESS は初めてです。（[インタビュー記事](http://gihyo.jp/lifestyle/serial/01/shukatsu_joshi/0004)が載ったり、他の方の記事で[自分の名前が出たり](https://gihyo.jp/dev/feature/01/webservice-guide/0002)、[自分が開発してるソフトウェアをとりあげてもらったり](http://gihyo.jp/magazine/wdpress/archive/2013/vol76)はしましたが。）

で、内容は読んでもらうとして、補足を。

## サンプルで利用してる CentOS がなぜ最新ではなく 6.4 なのか

執筆当初は、最新バージョンである 6.5 で進めていたのですが、DigitalOcean 上にある 6.5 のイメージには rsync が入っておらず、Vagrant によるプロビジョニングがエラーになる、ということが起きたため、rsync が入っている 6.4 に変更しました。

6.5 のままで行くためには、元のイメージに rsync を入れて、そのスナップショットをとって…みたいな作業が必要になって、それは本特集の趣旨から脱線するので、6.4 で行くことにしました。

Vagrant 1.5 からは Box に rsync が入っていない場合に自動で入れてくれる機能があるのですが、[vagrant-digitalocean](https://github.com/smdahlen/vagrant-digitalocean) を利用していると、この機能が発動しないんですよね。で、vagrant-digitalocean 利用時も自動で rsync を入れるための[プルリクエスト](https://github.com/smdahlen/vagrant-digitalocean/pull/103) を送っていて、+1 がいくつかついてるけど、まだマージされてないです。これがマージされてリリースされれば、rsync が入っていないイメージであっても、本特集に書いた手順そのままでいけるようになるはずです。

## サンプルコード

[gihyo.jp のサポートページ](http://gihyo.jp/magazine/wdpress/archive/2014/vol80/support#supportDownload) でも公開されてますが、[GitHub 上にも置いておきます](https://github.com/mizzy/test-driven-infra)。本特集通りに操作した履歴になっていますし、[章ごとにタグを打ってあります](https://github.com/mizzy/test-driven-infra/releases)。

## その他

その他、読んでいて何か気になる点、お気づきの点などありましたら、[@gosukenator](https://twitter.com/gosukenator) までお知らせください。
