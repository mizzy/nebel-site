---
layout: post
title: CobblerAndPuppet
date: 2009-11-15 21:09:29 +0900
---


検証用に VM をつくったり消したり、ってことをよくやるんですが、毎回毎回同じような設定をするのがいやなので、うちでは Cobbler + Puppet でこんな風にやってるよ、という例を紹介します。最近 KVM に移行しましたが、ブリッジの設定以外は、Xen でもほぼそのまま適用できると思います。

VM 作成のざっくりとした流れは次のような感じで、3 ステップで完了します。まず koan コマンドで以下のように VM インストールします。

	
	$ sudo koan --server localhost --virt --system=template --virt-name=test-vm
	

インストールが終わったら、VM を起動して、コンソールにアクセスします。

	
	$ sudo virsh start test-vm
	$ sudo virsh console test-vm
	

puppet をインストールして、実行します。

	
	# yum -y install puppet
	# puppetd --server puppet.hoge.com --verbose --no-daemonize --onetime
	

この時点で、毎回 VM を作成するたびに行っている、以下のような設定が既に完了している、という状態となります。

* yum リポジトリの設定
   * dag, epel に加えて、自前リポジトリを参照するように設定。
* NIC の設定
   * 複数 NIC の環境で検証したいこともあるので、自動的に eth0 と eth1 の NIC を設定。
* iptables を off
   * 検証環境ではとりあえず必要ないので。
* selinux を off
   * これも検証環境では必要ないので。
* ntp の設定
   * 検証によっては VM 間で時刻が正確に同期してる必要があるので。
* 最低限必要なパッケージのインストール。
   * zsh
   * screen
   * vim-enhanced
   * perl-ack
   * subversion
   * git
* /etc/sudoers の設定
   * 基本的には root ログインしないので、sudo できるようにしておく。
* nss_ldap/pam_ldap まわりの設定
   * LDAP アカウントで SSH ログインできるようにするのが主な目的。
   * アカウントを各 VM で管理するのがイヤなので、LDAP サーバで集中管理してます。
* autofs の設定
   * /home はファイルサーバをマウント。これにより、どの VM からも、/home が同じ内容で参照できる。
   * メインマシンである Mac からもファイルサーバをマウントしており、どの VM を使うことになっても、プログラム書いたりするのがすべて Mac 上の emacs で完結できるのでとても楽。

以下、このようなことを、具体的にどのような設定で実現しているのか、ざっくりとですが説明します。

----

# Cobbler まわりの設定

## Cobbler のインストールと設定

Cobbler サーバを立てて、インストール、設定を行います。ここの手順については省略。[この辺](http://trac.mizzy.org/public/wiki/Cobbler) を参照してください。（ただ若干情報古いです。）

## CentOS 5.4 の Cobbler へのインポート

	
	$ sudo cobbler import \
	  --mirror=rsync://ftp.jaist.ac.jp/pub/Linux/CentOS/5.4/os/x86_64/ \
	  --name=CentOS5.4-x86_64
	


## yum リポジトリの追加

cobbler repo add で、参照すべき yum リポジトリを追加します。

	
	$ sudo cobbler repo add \
	  --name=CentOS5-epel \
	  --mirror=http://download.fedoraproject.org/pub/epel/5/x86_64/ \
	  --mirror-locally=N
	$ sudo cobbler repo add \
	  --name=CentOS5-dag \
	  --mirror=http://ftp.riken.jp/Linux/dag/redhat/el5/en/x86_64/dag/ \
	  --mirror-locally=N
	$ sudo cobbler repo add \
	  --name=CentOS5-mizzy \
	  --mirror=http://hoge.mizzy.org/yum/centos/5/x86_64/ \
	  --mirror-locally=N
	$ sudo cobbler reposync
	

## profile にリポジトリ追加

	
	$ sudo cobbler profile edit \
	  --name=CentOS5.4-x86_64 \
	  --repos="CentOS5-epel CentOS5-dag CentOS5-mizzy"
	

## bridge の設定

[ここ](http://trac.mizzy.org/public/wiki/KvmOnCentOS54) を参考に、br0 というブリッジインターフェースをまず作成。こいつを VM 上の eth0 のブリッジとして利用するように、template という名前の system を登録する。

	
	$ sudo cobbler system add \
	  --name=template \
	  --profile=CentOS5.4-x86_64 \
	$ sudo cobbler system edit \
	  --name=template \
	  --interface=eth0 \
	  --virt-bridge=br0
	

また、libvirt 標準の virbr0 を eth1 のブリッジとして利用するように、system edit する。（eth1 は外と通信する必要がなく、 VM 同士でだけ通信できればいいので、virbr0 がそのまま使える。）

	
	$ sudo cobbler system edit \
	  --name=template \
	  --interface=eth1 \
	  --virt-bridge=virbr0
	

（本当は system じゃなくて profile でやりたいけど、profile では複数のブリッジの設定ができないっぽいので。）

## iptables/selinux の設定

Cobbler で参照してる kickstart ファイルに、以下のように設定するだけ。

	
	firewall --disabled
	selinux --disabled
	

----

# Puppet マニフェスト

Puppet サーバを用意し、以下のようなマニフェスト作成。Puppet のインストールや設定については省略。

## ntpd の設定

ntp パッケージをインストールして、ntpd を起動。

	
	package { 'ntp': ensure => present }
	
	service { 'ntpd':
	    enable => true,
	    ensure => running,
	}
	

## 必要なパッケージのインストール

この辺は kickstart で設定しても構わない。

	
	package {
	    'zsh':
	        ensure => present;
	    'screen':
	        ensure => present;
	    'vim-enhanced':
	        ensure => present;
	    'perl-ack':
	        ensure => present;
	    'subversion':
	        ensure => present;
	    'subversion':
	        ensure => present;
	    'git-all':
	        ensure => '1.6.5.2-1';
	}
	

## /etc/sudoers の設定

あらかじめ作成しておいた /etc/sudoers を Puppet で配布。

	
	package { 'sudo': ensure => installed }
	
	file { '/etc/sudoers':
	    source => "puppet://$server/dist/base/etc/sudoers",
	    mode   => 440,
	}
	

## nss_ldap/pam_ldap の設定

必要なパッケージインストール、NSS や PAM まわりの設定、nscd の起動なんかを行う。

	
	package {
	    'nss_ldap':
	        ensure => present;
	    'openldap':
	        ensure => present;
	    'nscd':
	        ensure => present;
	}
	
	service { 'nscd':
	    enable  => true,
	    ensure  => running,
	    require => Package['nscd'],
	}
	
	file { '/etc/pam.d/system-auth-ac':
	    source => "puppet://$server/dist/base/etc/pam.d/system-auth-ac",
	}
	
	file { '/etc/nsswitch.conf':
	    source => "puppet://$server/dist/base/etc/nsswitch.conf",
	}
	
	file { '/etc/ldap.conf':
	    source => "puppet://$server/dist/base/etc/ldap.conf",
	}
	

## autofs の設定

必要なパッケージのインストール、portmap や autofs の起動、/etc/auto.master, /etc/auto.home の設定を行う。

	
	package {
	    'autofs':
	        ensure => present;
	    'portmap':
	        ensure => present;
	    'nfs-utils':
	        ensure => present;
	}
	
	service { 'portmap':
	    enable  => true,
	    ensure  => running,
	    require => Package['portmap'],
	    before  => Service['autofs'],
	}
	
	service { 'autofs':
	    enable    => true,
	    ensure    => running,
	    require   => Package['autofs'],
	    subscribe => [ File['/etc/auto.master'], File['/etc/auto.home'] ],
	}
	
	file { '/etc/auto.master':
	    content => '/home /etc/auto.home',
	}
	
	file { '/etc/auto.home':
	    content => '* -fstype=nfs,soft,int,rsize=32768,wsize=32768,nosuid,nocache fileserver.hoge.com:/home/&',
	}
	

----

上記のような感じで Cobbler や Puppet の環境を構築しておくと、最初に書いたとおり、以下のようなステップで、必要な設定がなされた VM の作成がさくっと完了します。

	
	;; VM インストール
	$ sudo koan --server localhost --virt --system=template --virt-name=test-vm
	
	;; インストール後、起動してコンソールアクセス
	$ sudo virsh start test-vm
	$ sudo virsh console test-vm
	
	;; puppet インストールし/実行
	# yum -y install puppet
	# puppetd --server puppet.hoge.com --verbose --no-daemonize --onetime
	

[ここを参照すると](https://fedorahosted.org/cobbler/wiki/SupportForOtherDistros)、Cobbler は RedHat 系だけではなく、Debian, Ubuntu, SuSE あたりにも利用できるみたいなので、他の Linux ディストリビューションでも、同じような手順でいけそうですね。

他の OS だとどうなんだろう？
