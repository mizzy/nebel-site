---
layout: post
title: docs/YAPC-Assurer-ja-public.ppt
date: 2007-04-23 02:05:31 +0900
---
source:docs/YAPC-Assurer-ja-public.ppt

	
	 Assurer – A server testing/monitoring framework
	Gosuke Miyashita
	http://mizzy.org/
	自己紹介
	(� �)paperboy&co. 所属
	最近社内に Perl 仲間が増えて喜んでます
	ペパボサービスの表や裏で動いてるAPI周りの開発がメイン（Perl
	+ Catalyst）
	…のはずが、今は技術系何でも屋。最近は勤�� 管理用ウェブアプリとかつくってる
	Assurer とは？
	Plagger ライクなサーバテスト/監視用フレー�� ワーク
	プラグインメカニズ�� 
	YAMLで��定
	assetsの��在
	Test::Base によるテスト
	元々は想定通りにサーバが構築できているか、といった単発テスト用途で開発
	テストも監視も似たようなもの�� ろう、ってことで監視もカバーすることに
	
	Assurer 名前の由来
	��み方は「アシュラ」
	Plagger っぽいツールはみんな er で終わる
	Archer by tokuhirom
	Observer by はてな（非公開）
	Dishuber by Yappo
	Precure by ふしはらかん
	テストのことを「Quality Assurance」とも言うので
	
	Assurer 実行イメージ #0
	Assurer 実行イメージ #1
	Assurer の実行フェーズ
	Assurer の実行フェーズ
	Test フェーズ
	テストを実行
	Nofity フェーズ
	テスト結果を通知
	Format フェーズ
	テスト結果を整形
	Publish フェーズ
	整形されたテスト結果を出力
	各フェーズの関連
	各フェーズ詳細
	Test フェーズ
	Test フェーズ
	テストを実行するフェーズ
	以下の様なプラグインがある
	Test::HTTP
	Test::SMTP
	Test::DBI
	Test::Ping
	他
	Test フェーズのコンフィグ
	test:
	- module: HTTP
	config:
	host: www.mizzy.org
	content: It works!
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	MISS
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	Test
	Publish
	Format
	Nofity
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	publish:
	- module: Mail
	config:
	subject: Test results from Assurer
	to: someone@example.com
	from: root@example.com
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	test:
	- module: HTTP
	config:
	host: www0.mizzy.org
	
	- module: HTTP
	config:
	host: www1.mizzy.org
	
	------------------------------------------------------------------------
	
	
	test:
	- module: HTTP
	role: web
	
	hosts:
	web:
	- www0.mizzy.org
	- www1.mizzy.org
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	format:
	- module: Text
	filter:
	module: Status
	status: ok
	
	------------------------------------------------------------------------
	
	
	notify:
	- module: IRC
	filter:
	module: Status
	status: not ok
	
	------------------------------------------------------------------------
	
	
	format:
	- module: Text
	- module: HTML
	pusblish:
	- module: Term
	filter:
	module: Type
	type: text/plain
	- module: Mail
	filter:
	module: Type
	type: text/html
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	tests: # test is right
	- module: Test::HTTP
	$ ./assurer.pl -c config.yaml
	Assurer::ConfigLoader [fatal]
	- [/] Expected required key `test‘
	- [/tests] Unexpected key `tests' at line 46
	
	------------------------------------------------------------------------
	
	
	test:
	- module: HTTP
	config:
	contents: XXX # content is right
	$ ./assurer.pl -c config.yaml
	Assurer::ConfigLoader [fatal]
	Config error in Test::HTTP
	- [/contents] Unexpected key `contents' at line 66
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	$ ./assurer.pl --shell
	assurer> uptime
	[www.mizzy.org] 21:48:24 up 5 days, 23:08, 2 users, load average: 0.24,
1.16, 0.17
	[svn.mizzy.org] 21:48:24 up 5 days, 23:08, 2 users, load average: 0.24,
1.16, 0.17
	[ftp.mizzy.org] 21:48:24 up 5 days, 23:08, 2 users, load average: 0.24,
1.16, 0.17
	
	------------------------------------------------------------------------
	
	
	$ ./assurer.pl --shell --role=web
	assurer> uptime
	[www.mizzy.org] 21:48:24 up 5 days, 23:08, 2 users, load average: 0.24,
1.16, 0.17
	
	------------------------------------------------------------------------
	
	
	assurer> !on app1.foo.com \
	app2.foo.com do uptime
	# app1.foo.com と app2.foo.com 上でのみ実行
	assurer> !on /.*\.foo\.com/ do \
	uptime
	# .*\.foo\.com にマッチするホスト上でのみ実行
	
	------------------------------------------------------------------------
	
	
	assurer> !with web db do uptime
	# web ��ールと db ��ールに属するホスト上でのみ実行
	
	assurer> !with /web|mail/ do uptime
	# web または mail
	にマッチする��ールに属するホスト上でのみ実行
	
	------------------------------------------------------------------------
	
	
	assurer> !test HTTP
	Assurer::Plugin::Test::HTTP [info] Testing HTTP on www0.mizzy.org...
	ok 1 - HTTP status code of http://mizzy.org:80 is 200
	not ok 2 – Content of http://mizzy.org:80 matches 'It works!‘
	assurer>
	
	------------------------------------------------------------------------
	
	
	assurer> !test HTTP on app1.foo.com
	# 特定のホストにのみテスト実行
	assurer> !test HTTP on /.*.foo.com/
	# ��規表現も OK
	assurer> !test HTTP with web
	# 特定の��ールにのみテスト実行
	assurer> !test HTTP with /web|mail/
	# こちらも��規表現 OK
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	$ assurer.pl --para=20
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	localhost
	test0.mizzy.org
	www0.mizzy.org
	www1.mizzy.org
	www2.mizzy.org
	test1.mizzy.org
	test2.mizzy.org
	��  ssh assurer_test.pl
	③ 結果をリターン
	② テスト実行
	
	------------------------------------------------------------------------
	
	
	exec_on:
	- host: test0.mizzy.org
	priority: 3
	- host: test1.mizzy.org
	priority: 2
	- host: test2.mizzy.org
	priority: 1
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	# assurer.pl --discover -c template.yaml
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	# $host と $mechは Assure コアで実行時にプリセットされる
	$mech->get_ok("http://$host", "got htttp://$host");
	$mech->content_contains('It works!', "Content matches 'It works!'");
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	package Assurer::Plugin::Test::HTTP;
	use base qw( Assurer::Plugin::Test );
	use Assurer::Test;
	
	sub register {
	my $self = shift;
	$self->register_tests( qw/ status content server / );
	}
	
	sub status {
	my ( $self, $context, $args ) = @_;
	... ��略
	is( $res->code, '200',
	'HTTP status code of $self->{url} is 200' );
	}
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	assurer.pl
	Assurer::bootstrap()
	Assurer::Dispatch::run()
	呼び出し
	直接実行 or
	ssh でリモート実行
	テストを実行
	テスト結果
	を返す
	呼び出し
	assurer_test.pl
	assurer_test.pl
	assurer_test.pl
	assurer_test.pl
	assurer_test.pl
	Assurer::Result
	Assurer::Result
	Assurer::Result
	Assurer::Result
	Assurer::Result
	結果オブジェクト
	生成
	次のフェーズへ
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	assurer_test.pl -–config=LS0tCmNvbmZpZzoKICBjb250ZW50OiBJ
	dCB3b3JrcyEKICBob3N0OiB3d3cubWl6enkub3JnCm1vZHVsZTogSFRUUApuYW1lOiBIVFRQIHRlc3QKcm9sZTogd2ViCg==
	--context=LS0tICEhcGVybC9oYXNoOkFzc3VyZXIKYmFzZV9kaXI6IC9
	ob21lL21peWEvc3ZrL0Fzc3VyZXIKY29uZmlnOgogIGZvcm1hdDoKICAgIC0gY29uZmlnOiAmMSB7fQogICAgICBtb2R1bGU6IFRleHQKICBnbG9iYWw6CiAgICBob3N0OiB+CiAgICBpbnRlcnZhbDogMwogICAgbG9nOgogICAgICBsZXZlbDogZGVidWcKICAgIG5vX2RpYWc6IDAKICAgIHJldHJ5OiAzCiAgaG9zdHM6CiAgICBmdHA6CiAgICAgIC0gZnRwLm1penp5Lm9yZwogICAgc3ZuOgogICAgICAtIHN2bi5taXp6eS5vcmcKICAgIHdlYjoKICAgICAgLSB3d3cubWl6enkub3JnCiAgICAgIC0gc3ZuLm1penp5Lm9yZwogICAgICAtIHRyYWMubWl6enkub3JnCiAgbm90aWZ5OgogICAgLSBjb25maWc6CiAgICAgICAgYW5ub3VuY2U6IG5vdGljZQogICAgICAgIGNoYXJzZXQ6IGlzby0yMDIyLWpwCiAgICAgICAgZGFlbW9uX3BvcnQ6IDk5OTEKICAgICAgICBuaWNrbmFtZTogYXNzdXJlcmJvdAog
	... ま�� 続く
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	
	------------------------------------------------------------------------
	
	
	------------------------------------------------------------------------
	
	
	------------------------------------------------------------------------
	
	Created with pptHtml
	