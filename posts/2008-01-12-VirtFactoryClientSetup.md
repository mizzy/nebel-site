---
layout: post
title: VirtFactoryClientSetup
date: 2008-01-12 15:38:49 +0900
---


[前回](http://trac.mizzy.org/public/wiki/VirtFactoryServerSetup)に続き、今回はクライアント側の手順です。クライアント側では、必要なソフトウェアのインストールと、サーバへの登録を行います。

クライアントのサーバへの登録は、既に OS がインストールされた状態から行う方法と、OS がインストールされていないまっさらな状態から行う方法の2つがあります。 

以下、2つの方法について手順を解説します。これもサーバと一緒で、Fedora 7 で試しています。


# 既に OS がインストールされた状態から行う方法

## SELinux と iptables をオフに

とりあえず検証目的なので、こいつらはオフにしときます。手順は省略。 

## yum リポジトリの設定

これは [サーバ側の設定](http://trac.mizzy.org/public/wiki/VirtFactoryServerSetup#yum%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%81%AE%E8%A8%AD%E5%AE%9A) と同じなので省略。

## 必要なパッケージのインストール

Virt-Factory は仮想サーバの管理を行うためのものなので、当然何らかの仮想環境が必要。というわけで、Xen カーネルとツールをインストール。

	
	$ sudo yum install kernel-xen xen
	

それから、Python をアップデートしないと、後述する virt-factory-node-server でエラーが出たので、アップデートしておく。


	
	$ sudo yum update python
	

Xen カーネルで起動するために、再起動する。

現在の Virt-Factory は、Cobbler/Koan 0.6.2 を前提にしているため、バージョン指定で 0.6.2 をインストール。

	
	$ sudo yum install koan-0.6.2-1.fc7
	

その他必要なパッケージをインストール。

	
	$ sudo yum install virt-factory-nodes virt-factory-register libvirt-python
	

## サーバへの登録

Virt-Factory クライアントをサーバに登録するためには、次のコマンドを実行します。

	
	$ sudo vf_register --serverurl=http://server.example.org:5150 --profile=Container     
	

server.example.org の部分は、サーバ側で Python の socket.gethostname() で取得できるホスト名と同一である必要があります。（qpid でのメッセージング処理の関係で。）

登録が正常に完了すれば、サーバ側で ampm コマンドを実行して、確認することができます。（Web UI でも確認できます。）

	
	$ sudo ampm list hosts
	hostname: client.example.org id: 1 profile_name: Container::F-7-xen-i386 
	

最後に virt-factory-node-server を起動します。

	
	$ sudo /sbin/chkconfig virt-factory-node-server on
	$ sudo /etc/init.d/virt-factory-node-server start
	


# OS がインストールされていない状態からの登録

OS がインストールされていない場合、PXE ブートからネットワークインストールを行い、その流れでサーバへの登録まで一気にやってしまいます。これは、[前回の手順でインポートしたプロファイル](http://trac.mizzy.org/public/wiki/VirtFactoryServerSetup#yum%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%81%AE%E8%A8%AD%E5%AE%9A)の中で、これらの手順をすべてやるように指定されているので、特にこれ以上何かを設定する必要はありません。マシンを PXE ブートし、boot: プロンプトでプロファイル名 (Container::F-7-xen-i386)を入力すれば、あとは全て自動的に進んでいくはずです。（まだきちんと検証できてません。）

また、事前に Web UI で MAC アドレスを登録しておけば、boot: プロンプトにプロファイル名を入れる必要すらありません。


以上で、Virt-Factory クライアントのサーバへの登録は完了です。この後、ampm コマンドで、リモートの Virt-Factory クライアント上にコマンド一発でゲスト OS をインストールしたり、ゲスト OS の起動や停止をリモートから行ったり、複数のリモートクライアント上にあるゲスト OS をすべてリストアップしたり、といった、Virt-Factory のメインの使い方に入るわけですが、この解説はまた次回に。
