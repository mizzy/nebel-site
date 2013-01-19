---
title: RPM パッケージを Git で管理する方法（案）
date: 2013-01-17 18:05:44 +0900
---

[@trombik](https://twitter.com/trombik) さんの

<blockquote class="twitter-tweet"><p>弊社ではtinderbox+gitですべて統一させてる</p>&mdash; trombik (@trombik) <a href="https://twitter.com/trombik/status/284200636021608449" data-datetime="2012-12-27T07:34:46+00:00">December 27, 2012</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

という tweet を見て気になったので調べてみたところ、 [Tinderbox](http://tinderbox.marcuscom.com/) はどうやら FreeBSD の ports を自動ビルドするためのシステムのようで、RPM でもこんなのないのかなー、と探してみたものの見つけられなかったし、Tinderbox が自分が求めてるものなのかどうかもいまいちピンと来なかったので、プロトタイプ的なものをつくってみることに。

現在 RPM パッケージの管理は、[こんな感じで](https://github.com/paperboy-sqale/sqale-yum) ソース/バイナリパッケージを直接リポジトリに突っ込んじゃってるんだけど、これだと以下のような問題がある。

 * バイナリパッケージのファイルサイズが大きすぎて、git clone や push や pull に時間がかかる
 * パッケージ丸ごと突っ込んでるので、ファイル個別の差分が確認できない
   * そもそも差分確認できないものを突っ込むのは git を使う意義がだいぶ削がれる

それをこんな風にしたい。

 * 必要最小限のファイルだけを git リポジトリに突っ込んでファイル個別に差分確認できるように
 * パッケージは突っ込まず、git で管理してるファイルからパッケージビルドする
   * ただしソースパッケージは必要なら突っ込んでもOK

で、プロトタイプ的なものをつくってみたのがこれ。

[mizzy/how-to-manage-rpm-packages-with-git](https://github.com/mizzy/how-to-manage-rpm-packages-with-git)

このリポジトリの構成はこんな感じ。

```
|-- build.rb
|-- ffmpeg
|   |-- ffmpeg-github-0.8.2.spec
|   |-- libavformat-muxer.paperboy.patch
|   |-- libx264-superfast_firstpass.ffpreset
|   `-- libx264-veryfast_firstpass.ffpreset
|-- memcached
|   |-- memcached-1.4.15-1.el6.src.rpm
|   `-- memcached.spec
`-- ngx_openresty
    `-- ngx_openresty.spec
```

build.rb がビルド用のスクリプトで、それ以外に各パッケージ用のディレクトリがある。で、どのファイルをバージョン管理するかは、パッケージによって異なるだろうな、ってことで、あり得そうなパターンをいくつか用意してみた。

----

## パターン1: ngx_openresty

[これ](https://github.com/mizzy/how-to-manage-rpm-packages-with-git/tree/master/ngx_openresty) は spec ファイルだけを管理するパターン。spec の中に

```
Source0: http://agentzh.org/misc/nginx/ngx_openresty-%{version}.tar.gz
```

という記述があるので、こいつをダウンロードして ~/rpmbuild/SOURCES に置き、ソースパッケージとバイナリパッケージをビルド、という一番シンプルなパターン。

configure オプションぐらいをカスタマイズできればOK、という場合はこのパターンになるはず。


----

## パターン2: ffpmeg

[これ](https://github.com/mizzy/how-to-manage-rpm-packages-with-git/tree/master/ffmpeg) は spec ファイル＋パッチ（＋α）な構成。独自にパッチをあてて、パッチもバージョン管理したい、といったパターン。これも spec ファイルに


```
Source: http://www.ffmpeg.org/releases/ffmpeg-%{version}.tar.bz2
```

という記述があるので、こいつをダウンロードし、他のパッチファイル等とともに ~/rpmbuild/SOURCES に置いて、ソースパッケージとバイナリパッケージをビルドする。


----

## パターン3: memcached

[こいつ](https://github.com/mizzy/how-to-manage-rpm-packages-with-git/tree/master/memcached) は既存のソースパッケージのビルドオプションだけを変えたいんだけど、spec ファイル中のソースが

```
Source0:        http://memcached.googlecode.com/files/%{name}-%{version}.tar.gz
Source1:        memcached.sysv
```

となっていて、memcached.sysv をネットワーク越しに取得できない、かといって、このファイルは既存ソースパッケージに入ってるものをそのまま使うので、特にバージョン管理の必要はない、といったケース。

このケースであれば、既存ソースパッケージ内のファイルは、spec 以外は修正することはないからバージョン管理の必要はないし、バイナリパッケージと比べればサイズは小さいから、そのまま突っ込んじゃう方が楽だろう、ということで、src.rpm ファイルをリポジトリにそのまま突っ込んでる。（別に memcached.sysv だけ取り出して置いといてもいいんだけど、memcached.sysv 以外にも付随するソースやパッチがもっとたくさんある場合は、この方が楽だろう、という判断。）

----

今のところこれぐらいのパターンを網羅できれば大丈夫かなー、と。いずれのパターンでも、ファイル個別に差分の確認ができるし、管理すべきファイルのサイズも最小限に抑えられているし、ビルドに必要なファイルは一通り揃っている。

----

## パッケージのビルド

で、これらのファイルを git clone してきて、[build.rb](https://github.com/mizzy/how-to-manage-rpm-packages-with-git/blob/master/build.rb) みたいなスクリプトでビルド＆yum サーバへのデプロイ、ってなことができればいいなー、というのが最終的な目論見。

----

## その他

とりあえず自分のアイデアを形にしてみて、意見をもらったりとか、それ○○でできるよ、みたいな反応がもらえるといいな、というのがこのブログエントリを書いた目的。

あと、こんなのできればいいなー、と思っているのは、Ruby の Bundler みたいに、

```
Source: git://github.com/torvalds/linux.git, ref: dfdeb
```

とか spec に書いておくと、git clone して tar ball 作成して、そいつを使ってパッケージビルドできたりするといいなー、とか。

また、@trombik さんと twitter でやりとりしてる中で、[koji](https://fedorahosted.org/koji/wiki) という RPM ビルドシステムを見つけたんだけど、これも使えないか調べてみる。（が、自分がやりたいこととはちょっと違う感じ。）
