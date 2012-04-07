---
layout: post
title: Lisa07TechSession2ndDay
date: 2007-11-16 14:32:03 +0900
---


[LISA'07](http://www.usenix.org/events/lisa07/) テクニカルセッション2日目の、気になったテーマに関する簡単なメモ。

# Ganeti: An Open Source Multi-Node HA Cluster Based on Xen

Google でつくられている Xen ベースのオープンソースなマルチノード HA クラスタ（タイトルまんま）。[プロジェクトページはこちら](http://code.google.com/p/ganeti/)。

要するに HA + Virtualization。通常の HA は、実マシンから実マシンへフェイルオーバするけど、Ganeti では VM から VM へフェイルオーバーする、と。仮想化は Xen を利用しており、管理用コマンドラインツールには Python を、ディスク管理には LVM, DRBD, MD を、コマンドラインツールから各ノード（Xen dom0）やインスタンス（Xen domU）への命令実行は、Twisted や ssh を利用している。

管理コマンドはマスタノード上で実行する。

* gnt-node add/remove/list cluster nodes
* gnt-instance
   * add/remove
   * failover
   * stop/start change params
* gnt-os: instance os definitions
* gnt-cluster: cluster commands
* gnt-backup: instance export and import

すべてのコマンドには man ページとインタラクティブヘルプが用意されてる。

クラスタのセットアップは以下の様に実行する。（node0 というのがマスタノードらしい。）

	
	node0# gnt-cluster init mycluster
	node0# gnt-node add node1
	node0# gnt-node add node2
	node0# gnt-node add node3
	node0# gnt-cluster cmmand apt-get install ganeti-instance-etch
	

インスタンスの作成。

	
	node0# gnt-instance add -n node2:node1 -t drbd8 instance0
	

ノードがクラッシュした場合に別ノードに移行させる。

	
	node0# gnt-instance failover --ignore-consitency instance0
	node0# gnt-instance replace-disks -s --new-secodary=node3 instance0
	

クラスタのステータスチェックコマンド。

	
	node0# gnt-instance list
	node0# gnt-node list
	

サポートしているディスクタイプは、

* plain
* local_raid1
* remote_raid1
* drbd8(new)

remote_raid1 はなんかすごい複雑だった。こんな感じ。

	
	          +---------------+
	          | instance disk |
	          +---------------+
	                  |
	            +-----------+
	            | MD device |
	            +-----------+
	                  |
	           +-------------+
	           | DRBD device |
	           +-------------+
	             |         |
	  +------------+     +------------+
	  | LVM volume |     | LVM volume |
	  +------------+     +------------+
	        |                  |
	+----------------+ +----------------+
	| Physical disks | | Physical disks |
	|     node1      | |     node2      |
	+----------------+ +----------------+
	

DRBD8 を使えば、もっとシンプルにできるらしい。

ネットワークまわりの機能。（いまいちよくわからなかった。）

* Separate replication network
* multiple bridges/VLAN support
* Tagging(new)

Google での使われ方。

* 20-node Ganeti cluster
* 64-bit nodes OS
* 80 virtual isntances
* used for internal systems
* not used for google.com
* best for non-resource intensive systems

将来的に追加したい機能。

* automatic instance failover（ってことは今は自動でフェイルオーバーしない？）
* automatic node allocation
* master node election
* manage GUI / meta-cluster manager

全体的に気になること、わからないことだらけなんだけど、ソースが公開されてるから使ってみるのがてっとりばやそうだ。HA クラスタは今後うまく活用していきたいし、仮想化によるサーバ集約も興味があるので、時間を作ってぜひ検証してみたい。

そういえば、以前いた会社では、メールサーバなんかはよく HA クラスタ構成でサーバ構築してたけど、最近 HA クラスタはご無沙汰だなぁ。

Eメール送信元のレピュテーション（評価）を集約してシェアしよう、という試み。[概要はこちら](http://www.usenix.org/events/lisa07/tech/singaraju.html)。[プロジェクトページもある。](http://isr.uncc.edu/repuscore/)

SPF, DKIM, SenderID といったいわゆる送信者認証技術は、From ドメインと送信元サーバの組み合わせが正しいかどうかを判断することができるが、これが正しいからといって、スパマーかどうかは判断ができない。（実際、スパマーはいち早くこれらの送信者認証技術に対応してきているらしい。）それを補うのがこの RepuScore であり、送信元に関する評価を集合知的に集めてシェアすることが目的。

SpamAssassin 用プラグインを近々公開予定らしい。

RepuScore で興味深かったのは、不正なレポートを行う（Sybil attacksと呼んでいた）評価者の重みを下げることによって、評価全体への影響を低くして、不正なデータ操作が行えないようにする仕組みがあること。

他のレピュテーションシステムとしては、[SenderPath's Sender Score](http://www.returnpath.net/) や [Habeas' SenderIndex](http://www.habeas.com/en-US/Receivers/SenderIndex/) といったものがあるが、これらは IP アドレスベースのレピュテーションであり、RepuScore はドメインベースのレピュテーションである、という違いがある。（IPアドレスは組織間でシェアされていることもあるので、こういったレピュテーションシステムには向いていない、という記述もある。）

Gmail も自前でユーザに通知させるレピュテーションの仕組みを持っているが、Gmail の中で閉じられている。

