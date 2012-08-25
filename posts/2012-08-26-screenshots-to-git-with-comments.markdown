---
title: スクショをとってコメントつけて Git にアップする Automator Workflow つくってみた
date: 2012-08-26 01:03:23 +0900
---

Gyazo にコメントつけてアップしたい、といった要望があって、それと似たようなことを実現する Automator Wokflow をつくってみた。

このワークフローを起動すると、

{% img /images/2012/08/screenshot01.png %}

といったダイアログが出るので、領域選択してスクショを取得、すると、

{% img /images/2012/08/screenshot02.png %}

とコメントダイアログが出るので、コメントを入力して OK をクリックすると、入力したコメントをコミットメッセージとして、git commit & git push してくれる。

実際にこれを使ってスクショを GitHub にあげてみた履歴が[こちら](https://github.com/mizzy/screenshots/commits/master) 。

Automator Workflow は [こちらからダウンロード](https://github.com/mizzy/screenshots-to-git-with-comments/zipball/master) できます。利用の際には、画像保存先となる Git リポジトリがあるディレクトリ部分を適宜修正してください。

以下、Automator Workflow の各パーツを参考のために貼り付けておきます。

{% img https://raw.github.com/mizzy/screenshots/master/shot-20120826010951.png %}

{% img https://raw.github.com/mizzy/screenshots/master/shot-20120826011024.png %}

{% img https://raw.github.com/mizzy/screenshots/master/shot-20120826011121.png %}

{% img https://raw.github.com/mizzy/screenshots/master/shot-20120826011151.png %}

{% img https://raw.github.com/mizzy/screenshots/master/shot-20120826011222.png %}

{% img https://raw.github.com/mizzy/screenshots/master/shot.png %}






