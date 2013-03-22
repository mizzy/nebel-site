---
title: puppet-lxc-test-box
date: 2013-03-22 02:19:00 +0900
---

新たな Puppet のベストプラクティスを求めて、マニフェストの大規模なリファクタリングを行っています。

で、リファクタリングするからにはテストが必要だよね、ってことで、[rspec-puppet](http://rspec-puppet.com/) でテストを書いてるんだけど、rspec-puppet はマニフェストがコンパイルされた「カタログ」というものに対してテストするもので、実際にマニフェストを流し込んだ状態が正しいかテストするわけではないので、これだとテストとしては不完全。

というわけで、[Test Kitchen](https://github.com/opscode/test-kitchen) みたいに、同時にいくつも VM を立ててテストを走らせる、ってなことをやりたいんだけど、会社では KVM ベースの VM を利用してるので、VirtualBox ベースの Vagrant は使えないし、そもそもテストを動かす大元のホストも VM なので、VirtualBox どころか KVM も利用できない。


<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>


なので、まずは LXC のシステムコンテナをさくさくと作るための Puppet モジュールを書いてみた。

[puppet-lxc-test-box](https://github.com/mizzy/puppet-lxc-test-box)

( [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc) というのもあるけど、"Vagrant >= 1.1.0, the lxc package and a Kernel higher than 3.5.0-17.28, which on Ubuntu 12.10 means something like" ってなことが書かれていて、メインで使ってる RedHat 系 OS では動く気がしないのでスルー。)

使い方は次のような感じ。まず lxc-test-box モジュールと sysctl モジュールを持ってくる。

```
$ git clone git://github.com/mizzy/puppet-lxc-test-box.git lxc-test-box
$ git clone git://github.com/duritong/puppet-sysctl.git sysctl
```

以下のように、Exec リソースのデフォルト値と、システムコンテナのホスト名と IP アドレスを書いたマニフェスト lxc-test-box.pp を作成。

```
include lxc-test-box

Exec { path => '/sbin:/usr/sbin:/bin:/usr/sbin' }

lxc-test-box::lxc::setup { 'base':   ipaddress => '172.16.0.2' }
lxc-tets-box::lxc::setup { 'manage': ipaddress => '172.16.0.3' }
lxc-test-box::lxc::setup { 'smtp':   ipaddress => '172.16.0.4' }
```

マニフェストを流し込む。

```
$ sudo puppet apply --modulepath=. lxc-test-box.pp
```

これで、ホスト OS への lxc パッケージのインストール、ブリッジインターフェース br0 の作成、IP マスカレードの設定を行い、指定されたホスト名と IP アドレスでシステムコンテナを作成し、コンテナの起動までしてくれる。所要時間は、コンテナひとつあたり5分ぐらい。

起動したら、

```
$ ssh root@base.lxc-test-box
```

で、ログインできる。ログイン用の鍵は Puppet で設定済み。（ただし、鍵は /root/.ssh 以下に置いてあるので、必要ならそこからコピーを。）テスト目的なのでホストOSとは通信できるけど、外部からは通信できない。ただし、ホスト OS で IP マスカレードの設定はしてあるので、コンテナから外部への通信は可能。

同梱している lxc パッケージは Scientifix Linux 6.2 + Kernel 2.6.32-358.2.1.el6.x86_64 上でビルドしたものなので、RedHat 6 系以外ではたぶん動かないし、カーネルバージョンが違うと動かないかもしれない。

これでテスト用のシステムコンテナを量産できるようになったので、次は実際にテストする仕組みを作り込む。

----
KVM な VM の上で KVM な VM は動かせない、と思っていたら、[@usrm](https://twitter.com/ursm) さんから、最近のカーネルであればネストできるはず、という情報をいただきました。

<blockquote class="twitter-tweet"><p>@<a href="https://twitter.com/gosukenator">gosukenator</a> 最近のカーネルであれば KVM のネストはできるはずです <a href="http://t.co/HZf5HhhUYs" title="http://networkstatic.net/nested-kvm-hypervisor-support/">networkstatic.net/nested-kvm-hyp…</a></p>&mdash; Keita Urashima (@ursm) <a href="https://twitter.com/ursm/status/314802865313042432">March 21, 2013</a></blockquote>

とても有益な情報ありがとうございます！今度試してみよう。

