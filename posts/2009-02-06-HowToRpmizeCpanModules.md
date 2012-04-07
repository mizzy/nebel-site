---
layout: post
title: HowToRpmizeCpanModules
date: 2009-02-06 21:53:30 +0900
---


[Wassr](http://wassr.jp/) で [ZIGOROu さん](http://d.hatena.ne.jp/ZIGOROu/) や [hidek さん](http://blog.hide-k.net/) とやりとりした内容をまとめてみます。

CPAN モジュールの rpm パッケージ作成なんですが、自分は[RPM::Specfile](http://search.cpan.org/dist/RPM-Specfile/) に付属している、cpanflute2 を基本的に使ってます。

[cpan2rpm](http://perl.arix.com/cpan2rpm/) の方がメジャーだとは思うんですが、オリジナルのダウンロード用FTPサイトが接続できないのと、吐き出す SPEC ファイルが微妙な感じがするので、なんとなくイヤで使ってないんですが、それ以外はそんなに明確な理由もなく、cpanflute2 の方を使ってます。

ただ、cpanflute2 には以下の問題点があります。

* 依存関係を自動的に解決してくれない（これは cpan2rpm も同じ）
* モジュールの tar ball を自分で取得しないといけない（cpan2rpm はsearch.cpan.org から取得してくれる）

なので、[cpanflute2_wrapper.pl](http://gist.github.com/59314) といったラッパースクリプトを書いて使ってます。これを使うと、

	
	$ cpanflute2_wrapper.pl --buildall Catalyst::Runtime
	

みたいに実行すると、Catalyt::Runtime とそれに依存するモジュールの srpm と rpm を「半自動」で全部作ってくれます。--buildall とかのオプションは、中で呼び出される cpanflute2 にそのまま渡されます。

「半自動」と言ってるのは、スクリプトがいろいろとイケてなくて、場合によっては途中でこけてるのを目視で確認して、依存関係を自分で解決しないといけない時があったりするからです。あと、エラー処理やエラーメッセージもイケてなくてわかりにくかったり、ということもあって、今まで公開してなかったんですが、Wassr の流れで gist にスクリプト貼り付けちゃったので、ここでまとめてみることにしました。

他にも注意点があって、まずは rpmbuild の問題。rpmbuild でパッケージを作る際に、use/require してるモジュールがすべて勝手に SPEC ファイルのRequires に含まれてしまう、という問題があります。eval しているモジュールは依存関係の対象とはならないが、以下のように複数行にまたがっていると、依存関係の対象になってしまう。

	
	eval {
	    require 'Hoge';
	}
	

そのせいで、Linux 上でビルドしてるのに、Requires に Win32::*** が含まれる、ということがあったりします。で、Requires に含まれないようにするためには、/usr/lib/rpm/perl.req を以下のように修正します。（cpanflute2 が Makefile.PL を見て Requires に加えてくれるので、rpmbuild で Requires の処理してる部分はコメントアウトしちゃう。）

	
	#!diff
	--- /usr/lib/rpm/perl.req.org   2008-01-31 19:21:31.000000000 +0900
	+++ /usr/lib/rpm/perl.req       2008-01-31 19:21:41.000000000 +0900
	@@ -221,8 +221,8 @@
	
	       ($module  =~ m/\.ph$/) && next;
	
	-      $require{$module}=$version;
	-      $line{$module}=$_;
	+      #$require{$module}=$version;
	+      #$line{$module}=$_;
	     }
	
	   }
	


それから、cpanflute2自体に問題があって、以下のパッチをあてておく必要がある。

	
	#!diff
	--- cpanflute2.org      2008-02-26 12:20:28.000000000 +0900
	+++ cpanflute2  2008-02-26 12:21:15.000000000 +0900
	@@ -159,10 +159,12 @@
	       my $yaml = Load($contents);
	
	       while (my ($mod, $ver) = each %{$yaml->{build_requires}}) {
	-       push @build_requires, [ "perl($mod)", $ver ];
	+        $mod = "perl($mod)" if $mod ne 'perl';
	+       push @build_requires, [ "$mod", $ver ];
	       }
	       while (my ($mod, $ver) = each %{$yaml->{requires}}) {
	-       push @requires, [ "perl($mod)", $ver ];
	+        $mod = "perl($mod)" if $mod ne 'perl';
	+       push @requires, [ "$mod", $ver ];
	       }
	     }
	
	@@ -289,12 +291,7 @@
	 my $makefile_pl = qq{CFLAGS="\$RPM_OPT_FLAGS" %{__perl} Makefile.PL < /dev/null};
	 my $make_install = qq{make pure_install PERL_INSTALL_ROOT=\$RPM_BUILD_ROOT};
	
	-if ($use_module_build) {
	-  $makefile_pl = qq{CFLAGS="\$RPM_OPT_FLAGS" %{__perl} Makefile.PL destdir=\$RPM_BUILD_ROOT $installdirs < /dev/null};
	-}
	-else {
	-  $makefile_pl = qq{CFLAGS="\$RPM_OPT_FLAGS" %{__perl} Makefile.PL $installdirs};
	-}
	+$makefile_pl = qq{CFLAGS="\$RPM_OPT_FLAGS" %{__perl} Makefile.PL $installdirs};
	
	 $spec->build(<<EOB);
	 $makefile_pl
	

前半の修正は、Makefile.PL の PREREQ_PM とか requires とかに perl が含まれていると、SPEC ファイルの Requires に perl(perl) とか入っちゃっておかしなことになるので、そうならないように修正。

後半の修正は、なんで修正したかあまり覚えてないんだけど、時々 RPM_BUILD_ROOT がおかしくなることがあって、それに対する修正だったと思う。

そういえば、[まっさらなサーバを30分で本番投入できるようにする](http://d.hatena.ne.jp/stanaka/20070728/1185605498) で stanaka さんが「CPANの依存関係を解析してrpm化する手製スクリプトで、CPANモジュールのrpm化が、ほぼ自動化されています」と書いてるんだけど、これって公開してくれないのかなー。