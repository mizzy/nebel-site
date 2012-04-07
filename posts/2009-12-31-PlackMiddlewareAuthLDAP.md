---
layout: post
title: PlackMiddlewareAuthLDAP
date: 2009-12-31 11:22:58 +0900
---
*追記*

miyagawa さんから助言があり、authenticator 追加するだけでサブクラスが増えると使いにくいというのと、[Authen::Simple::LDAP](http://search.cpan.org/~chansen/Authen-Simple-LDAP/) を使えば、LDAP で認証するためにそれほどコード書くこともないので、わざわざモジュール化する必要もない、ということで、github からは削除することにしました。

また、Plack::Middleware::Auth::Basic の authenticator に Authen::Simple オブジェクトがそのまま渡せるように miyagawa さんが修正してくださいました。

http://github.com/miyagawa/Plack/commit/9f1ad6a3c2f33cd8f37c6cfcbb0993c55c84bbb9

これで Plack::Middleware::Auth::Basic そのままで、以下のような感じで LDAP で認証できます。

	
	#!perl
	use Authen::Simple::LDAP;
	enable "Auth::Basic", authenticator => Authen::Simple::LDAP->new(...);
	

miyagawa さん、ありがとうございました。

----

最近公私ともに、いちからウェブアプリ（ウェブ API 除く）書いてなくて、久々にウェブアプリを書こうかな−、と思いながらも、フレームワークに何を使おうか迷っていて、[Ark Advent Calendar 2009](http://opensource.kayac.com/ja/projects/ark/advent/2009/) を読んだり、[Amon](http://d.hatena.ne.jp/tokuhirom/20091230/1262133671) をウォッチしたりして、この年末を過ごしています。

で、いずれのフレームワーク使うにしても、Plack はキーになりそうだな、ってことで、LDAP で認証するための Plack::Middleware を書いてみました。


http://github.com/mizzy/p5-plack-middleware-auth-ldap

[Plack::Middleware::Auth::Basic](http://search.cpan.org/~miyagawa/Plack/lib/Plack/Middleware/Auth/Basic.pm) を継承し、authorizer を追加する形で実装しています。

ネームスペースは Plack::Middleware::Auth::Basic::LDAP の方がいいのかな、とか、ダイジェスト認証対応しようと思ったら、別モジュールにした方がいいのか、合わせてひとつのモジュールにした方がいいのか、その場合のネームスペースはどうすればいいのか、など、色々固まってない点があるので、まだ CPAN にはアップしない予定です。が、とりあえず自分で使う分には問題なく動いてるっぽいです。


