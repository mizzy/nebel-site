---
layout: post
title: PuppetAtHbStudy8
date: 2010-02-24 23:43:33 +0900
---


[hbstudy#8](http://heartbeats.jp/hbstudy/2010/02/hbstudy8.html) で、「Puppet のススメ」というタイトルでプレゼンさせていただきました。機会をくださった[株式会社ハートビーツ](http://heartbeats.jp/)の藤崎さん、馬場さん、坂口さん、また、運営スタッフのみなさま、聞きに来て下さったみなさま、twitter やブログで感想述べてくださったみなさま、本当にありがとうございました。

当日の資料は [slideshare にアップしています](http://www.slideshare.net/mizzy/puppet-3258268)。

内容は主に Puppet を知らない方、これから使ってみようかどうか検討している方をターゲットとして、

* Puppet とはどんなものか
* どんな風に動かすのか
* どういった使い方をすればいいのか
* 使うために知っておいた方がいいこと
* 使ってみて微妙だなと思うところ

といったお話をさせて頂きました。Puppet を既に実運用でバリバリ使っている方には、特に目新しい話はなかったと思いますが、そういった方からは逆にこちらが知らないこと、見落としてること、間違ってることなんかの情報をもらえればいいなー、という思いでプレゼンさせていただきました。

これだけではなんなので、プレゼンの補足事項とか、twitter のハッシュタグ #hbstudy やブログなんかで色々コメント頂いてますので、その辺まとめてみようと思います。

まずは twitter からいくつかピっくアップしてみます。

  matsuu puppetの気づきにくいメリットの１つは、puppetをいつでもやめられること。puppetをやめても既存の設定はpuppetに依存しないのでいつでもやめられる。これ大きいよね。 http://twitter.com/matsuu/statuses/9521601261

これは確かにおっしゃる通りですね。Puppet でサーバ構築しても、できあがったものは特に Puppet に縛られるものではないので、いつ使うのやめても大丈夫です。そして、プレゼンでも触れましたが、単に動かしてみるだけなら、比較的さくっと試せます。使いはじめる、あるいは使うのをやめる敷居が低い、というのは良いツールの条件だと思いますので、これはとても大きいメリットですね。

  yuzorock puppetの気付きにくいメリットの1つはsshではないこと。 http://twitter.com/yuzorock/statuses/9521698444

おっしゃる通り、メリットでもあると思うのですが、[sshd で代用できたらいいのに](http://d.hatena.ne.jp/tokuhirom/20100224/1266979391) という意見もあったりで、ここはなかなか難しい問題だなー、と思います。SSH ではないことは、メリットでもあるしデメリットでもありそうですね。メリットとしては、SSH 経由でマニフェストを適用するとなると、そのためのユーザ管理や鍵の管理、sudo まわりの設定、といったものが必要になるけど、そういった手間がかからない、といったところでしょうか。（他にもあれば教えて下さい。）逆にデメリットとしては、デーモンが常時上がってるとメモリ食うし、常にあがってる必要がないものがあがってる、という気持ち悪さ、といったあたりですかね。とくに、運用監視系のツールを色々入れていて、それぞれがデーモン持ってる、という状態はあまり好ましくないのではないかと思います。

  xaicron manifest の学習コストはどうなんだろ http://twitter.com/xaicron/statuses/9521881525

  yuzorock manifestの学習コストはたいしたこと無い。コマンド打つのとやることは同じだから。 http://twitter.com/yuzorock/statuses/9521927420

ここは感じ方は人それぞれだと思うので、一般的に学習コストがどうなのかを言うのは難しいのですが、自分は yuzorock さんと同意見で、それほど学習コスト高くないと思っています。

  matsuu #hbstudy puppetでcron設定管理してるとcrontabがどんどん汚れていくんだぜ...gentooだけかも http://twitter.com/matsuu/statuses/9522038117

最近はマニフェストで cron リソース定義するよりも、file リソースで /etc/cron.d にファイル置く方がわかりやすいかな、と思ったりしてます。

  matsuu あ、puppetのテンプレートの機能の話でてきた？ http://twitter.com/matsuu/statuses/9522545344

すみません、忘れてました！話したいことが多すぎて…テンプレートについて詳しく知りたい方は、 http://gihyo.jp/admin/serial/01/puppet/0007 とか Software Design の記事なんかをご覧ください。

  hirose31 なにげに PSP がリモコン http://twitter.com/hirose31/statuses/9522592495

[スライド操作パネル for PSP](http://coderepos.org/share/wiki/PSPSlidePanel) つかってます！これは超便利です。スライドの進行状況と残り時間がわかりやすく視覚化されるので、話しながら時間調整ができます。（Puppet関係ないですね。）

  mkouhei うーむ、良い点よりも不満の方が多いように聞こえる。 http://twitter.com/mkouhei/statuses/9522637899

デメリットに触れているような文章はあまり見かけないので、敢えて不満点を色々上げてみましたが、こっちの方が目立っちゃいましたかね。自分としてはとても良いツールだと思っています。

次はブログから拾ってみます。

[tokuhirom さんのブログ](http://d.hatena.ne.jp/tokuhirom/20100224/1266979391)。tokuhirom さんの感想を見て思ったのは、Puppet を導入してメリットがあるかどうか、というのは、どういう状況に置かれてるのか、どういったことをツールで解決したいのか、に大きく依存するので、それ抜きでは語れないな、と。Puppet に限った話でもないし、当り前のことなのですが、再確認させていただきました。

これと併せて [n0ts さんのブログ](http://www.sssg.org/blogs/naoya/archives/1717) を読んでみると、やはり重要なのは、「いかに楽をするか」だよね、と。n0ts さんの意見にとても賛成です。でも、置かれてる状況や人によって、「どこで楽をするのか」は異なってきそうですね。tokuhirom さんの感想にある、

  「シェルスクリプトで構築すればこれ簡単なのに!」みたいな場合に、いちいち puppet rule 書くのダルくね?

も、構築を自動化する、というポイントに置いて楽をしたいのであれば、シェルスクリプトでやっちゃうのが楽だと思います。そこを少し視線を変えて、構築シェルスクリプトはずっとメンテし続ける必要があるし、かといって作成した人がずっとメンテできるわけではないし、ずっとメンテできるとしても、長年メンテしつづけて作成した人にとってもカオスになることもあり得る、という状況が考えられる場合には、Puppet も選択肢のひとつとして検討に値する、といったことになるのではないかと。これはまさに、tokuhirom さんの感想にある

  自由度を制限して、属人性を排除するというアプローチはアリだとおもう。

の通り、属人性を排除する、ということを考えると、Puppet は有力な選択肢になる、という例だと思います。