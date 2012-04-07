---
layout: post
title: SetupRemedie
date: 2009-01-13 14:05:45 +0900
---
overlast さんの[これから15分で Remedie を始めるための資料](http://overlasting.dyndns.org/2009-01-07-1.html) に触発されて書いてみました。こっちは CPAN モジュールをインストールする時間も入れて15分。ただし限定された環境のみ。

Remedie 用に CPAN モジュールの RPM パッケージ作ったので、これプラス Puppet を利用します。ただし、RPM パッケージを CentOS 5 x86_64 でビルドしてるので、この環境限定。[SRPM](http://svn.mizzy.org/public/yum/SRPMS/) はあるので、他の環境の方はこいつをビルドして使ってください。

まずは Puppet をインストールするための yum リポジトリ設定。以下の内容で /etc/yum.repos.d/dlutter.repo を作成。

	
	[dlutter]
	name=lutter
	baseurl=http://people.redhat.com/dlutter/yum/rhel/$releasever/$basearch/
	enabled=1
	gpgcheck=0
	

Puppet のインストール。

	
	# yum -y install puppet-server
	

Puppet で署名するのはだるいので、以下の内容で /etc/puppet/autosign.conf を作成。

	
*
	

/etc/puppet/manifests ディレクトリを作成。

	
	# mkdir /etc/puppet/manifests
	

以下の内容の /etc/puppet/manifests/site.pp を作成。

	
	node default {
	
	  yumrepo {
	    'mizzy':
	      baseurl  => 'http://svn.mizzy.org/public/yum/RPMS/centos/$releasever/$basearch/',
	      enabled  => 1,
	      gpgcheck => 0;
	    'dag':
	      baseurl  => 'http://ftp.riken.jp/Linux/dag/redhat/el$releasever/en/$basearch/dag/',
	      enabled  => 1,
	      gpgcheck => 0;
	    'updates':
	      exclude => 'perl';
	    'extras':
	      exclude => 'perl';
	  }
	
	  Package {
	    require => [ Yumrepo['mizzy'], Yumrepo['dag'], Yumrepo['updates'], Yumrepo[extras] ],
	  }  
	
	  package {
	    'git':
	      ensure => present;
	    'perl':
	      ensure => '5.8.8-15.1';
	    'perl-Moose':
	      ensure => present;
	    'perl-Class-C3':
	      ensure => present;
	    'perl-Sub-Name':
	      ensure => present;
	    'perl-Devel-GlobalDestruction':
	      ensure => present;
	    'perl-Rose-DB':
	      ensure => present;
	    'perl-Rose-DB-Object':
	      ensure => present;
	    'perl-DateTime-TimeZone':
	      ensure => '0.8301-8';
	    'perl-MooseX-Types-Path-Class':
	      ensure => present;
	    'perl-DBD-SQLite':
	      ensure => present;
	    'perl-FindBin-libs':
	      ensure => present;
	    'perl-HTTP-Engine':
	      ensure => present;
	    'perl-MIME-Types':
	      ensure => present;
	    'perl-Path-Class-URI':
	      ensure => present;
	    'perl-String-CamelCase':
	      ensure => present;
	    'perl-Log-Dispatch':
	      ensure => present;
	    'perl-JSON-XS':
	      ensure => present;
	    'perl-MooseX-Getopt':
	      ensure => present;
	    'perl-MooseX-ConfigFromFile':
	      ensure => present;
	    'perl-File-Find-Rule':
	      ensure => present;
	    'perl-UNIVERSAL-require':
	      ensure => present;
	    'perl-Class-Accessor':
	      ensure => present;
	    'perl-DateTime-Format-Strptime':
	      ensure => present;
	    'perl-Feed-Find':
	      ensure => present;
	    'perl-Class-ErrorHandler':
	      ensure => present;
	    'perl-XML-Atom':
	      ensure => present;
	    'perl-XML-XPath':
	      ensure => present;
	    'perl-XML-Feed':
	      ensure => present;
	    'perl-Template-Toolkit':
	      ensure => present;
	    'perl-DateTime-Format-ISO8601':
	      ensure => present;
	    'perl-MooseX-ClassAttribute':
	      ensure => present;
	    'perl-XML-OPML-LibXML':
	      ensure => present;
	    'perl-File-Find-Rule-Filesys-Virtual':
	      ensure => present;
	    'perl-HTTP-Response-Encoding':
	      ensure => present;
	    'perl-HTML-ResolveLink':
	      ensure => present;
	    'perl-HTML-Selector-XPath':
	      ensure => present;
	    'perl-HTML-TreeBuilder-XPath':
	      ensure => present;
	    'perl-YAML':
	      ensure => present;
	    'perl-YAML-Syck':
	      ensure => present;
	    'perl-HTML-Scrubber':
	      ensure => present;
	    'perl-Image-Info':
	      ensure => present;
	    'perl-Text-Tags':
	      ensure => present;
	    'perl-XML-RSS-LibXML':
	      ensure => present;
	    'perl-Web-Scraper':
	      ensure => present;
	  }
	
	}
	

puppetmasterd を起動。

	
	# puppetmasterd --verbose --no-daemonize
	

puppetd を起動して、マニフェストを適用。注意点としては、localhost とかではなく、きちんと FQDN で指定すること。（puppetmasterd 初回起動時に自動作成される証明書中の CN と --server で指定するサーバ名が一致してないと怒られる。）

	
	# puppetd --server host.example.org --verbose --no-daemonize
	

このままログを見ながらしばらく待つ。完了したら Remedie を github.com から取得して起動。

	
	# git clone git://github.com/miyagawa/remedie.git
	# cd remedie
	# perl -Ilib -MRemedie::DB::Schema -e 'Remedie::DB::Schema->install'
	# ./bin/remedie-server.pl
	

自分でやったら10分ぐらいで終わった。
