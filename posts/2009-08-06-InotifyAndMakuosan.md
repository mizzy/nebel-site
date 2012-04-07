---
layout: post
title: InotifyAndMakuosan
date: 2009-08-06 08:05:40 +0900
---


ファイルのミラーリングツールとしては rsync が最も使われていると思いますが、差分チェックの負荷が大きく、できればつかうのやめたいなー、と思っていたところ、[Software Design 2009年8月号](http://gihyo.jp/magazine/SD/archive/2009/200908) に [lsyncd](http://code.google.com/p/lsyncd/) というツールが載っていて、お、これはと思って見てみたのですが、仕組みとしては inotify + rsync なので、結局は rsync を裏で呼び出していて、差分チェックの呪縛からは逃れられません。

inotify でファイルの更新イベント受け取ってるんだから、さらに rsync で差分チェックする必要はないじゃん、と思うわけですが、なんらかの理由でイベントが受け取れない可能性もあるため、二重チェックした方が安全なんでしょうね。

でもやっぱり余分な負荷はかけたくない、ってことで思いついたのが、inotify で更新イベントを検知したファイルを、[makuosan](http://lab.klab.org/wiki/Makuosan) の msync コマンドに渡してミラーリングする方法。（makusan の詳しい解説は、[WEB+DB PRESS Vol.51](http://gihyo.jp/magazine/wdpress/archive/2009/vol51) に載ってます。）

そこで以下のようなコードを書いて動かしてみたところ、いい感じでファイルが同期できることを確認しました。

	
	#!perl
	#!/usr/bin/perl
	
	use strict;
	use warnings;
	use File::ChangeNotify;
	
	my $base = '/home/miya/work';
	my $watcher = File::ChangeNotify->instantiate_watcher(
	    directories => [ $base ],
	);
	
	while ( my @events = $watcher->wait_for_events() ) {
	    for my $event ( @events ) {
	        my $path = $event->path;
	        $path =~ s!$base/!!;
	        `msync --sync $path`;
	    }
	}
	
	exit;
	

とは言っても、実運用で使うためには、イベントをとりこぼさない、またはとりこぼしてもリカバーするような仕組みを考えたり、負荷テストをしてみたりとか、色々と考慮しなければいけないことはありますが、それはまあおいおいってことで。

また、[File::ChangeNotify](http://search.cpan.org/~drolsky/File-ChangeNotify/) がすべての inotify イベントに対応してるわけではなく、IN_CREATE, IN_MODIFY, IN_DELETE にしか対応してないため、パーミッション変更とかファイルの移動なんかは検知できない、という問題もあります。（パッチ書けばいけそうなので、書いてみるつもりです。）

File::ChangeNotify 自体は inotify だけじゃなく、他の仕組みにも対応できるようになっていて、inotify が使える Linux kernel 2.6.13 以降であれば File::ChangeNotify::Watcher::Inotify が、それ以外であれば File::ChangeNotify::Watcher::Default が自動的に呼ばれるようになってます。なので、Mac OS X の FSEvents に対応した File::ChangeNotify::Watcher::FSEvents とか書けば、Mac では自動的に FSEvents で更新イベントを検知、ってこともできそうです。

ともかく、rsync の負荷には困っているので、今後この辺の方法論は詰めていきたいな、と思っています。

*追記*

[miyagawa さんによる File::ChangeNotify::Watcher::MacFSEvents が github にありました](http://github.com/miyagawa/File-ChangeNotify-Watcher-MacFSEvents/tree)。ただし、FSEventsではファイル名とかイベントの種類はとれないそうです。Wikipedia 見てもそんな感じのことが書いてますね。
