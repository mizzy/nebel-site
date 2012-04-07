---
layout: post
title: ScalableStorageWithOSS01
date: 2008-12-28 17:21:40 +0900
---


[wiki:ScalableStorageWithOSS00 OSS だけでスケーラブルなストレージを安価に構築する方法 #0] のつづき。

# サーバ構成概要

[TLUG 発表資料](http://www.slideshare.net/mizzy/how-to-build-a-scalable-storage-system-at-tlug-meeting-20080913-presentation) で触れた、全体的な構成のおさらい。構成図は以下のような感じ。

[[Image(http://trac.mizzy.org/public/attachment/wiki/ScalableStorageWithOSS01/scalable_storage.jpg?format=raw)]]


この構成について説明すると、以下のようになります。

* DRBD により、2台一組でブロックデバイスをミラーリング
   * /dev/gnbd0 と /dev/gnbd1 がセット
   * /dev/gnbd2 と /dev/gnbd3 がセット   
* GNBD でブロックデバイスをエクスポート
   * /dev/gnbd0, /dev/gnbd1, /dev/gnbd2, /dev/gnbd3 がネットワーク越しに見える
* クライアント側で GNBD でエクスポートされたブロックデバイスをインポート
   * /dev/gnbd0, /dev/gnbd1, /dev/gnbd2, /dev/gnbd3 をすべてインポート
* DM-MP により、2つのデバイスを1つに見せる
   * /dev/gnbd0 + /dev/gnbd1 が /dev/mapper/mpath0 として見える
   * /dev/gnbd2 + /dev/gnbd3 が /dev/mapper/mpath1 として見える
* CLVM により論理ボリュームを作成                 
   * /dev/mapper/mpath0 と /dev/mapper/mpath1 が物理ボリューム
   * この2つの物理ボリュームから、ボリュームグループ VG0 を作成
   * VG0 上に論理ボリューム LV0 を作成
   * この論理ボリュームが、/dev/VG0/LV0 として見える
* /dev/VG0/LV0 を GFS2 でフォーマット
* ストレージ全体が論理ボリューム /dev/VG0/LV0 として見えるので、こいつをマウントする

# 構築手順概要

構築手順はざっと以下のようになります。CentOS 5.2 + Xen で検証しています。

* Xen インスタンスをつくる
   * client0, client1
   * storage0a, storage0b
   * storage1a, storage1b
* ストレージサーバで GNBD によりエクスポートするブロックデバイスを作成する
* 2台セットで DRBD ミラーリング
   * storage0a と storage0b を同期
   * storage1a と storage1b を同期
* storage![01][ab] で GNBD によりブロックデバイスをエクスポート
* client![01]でブロックデバイスをインポート
* client![01]上で、DM-MP により複数のデバイスをまとめる
   * storage0[ab] からエクスポートしたデバイスをひとつに見せる
   * storage1[ab] からエクスポートしたデバイスをひとつに見せる
* DM-MP でまとめたデバイスを、CLVM によりひとつの論理ボリュームに見せる
* 論理ボリュームを GFS2 でフォーマットする
* 論理ボリュームをマウントする

次回以降、それぞれについて解説していきます。


* [wiki:ScalableStorageWithOSS00 OSS だけでスケーラブルなストレージを安価に構築する方法 #0]
* [wiki:ScalableStorageWithOSS02 OSS だけでスケーラブルなストレージを安価に構築する方法 #2]
* [wiki:ScalableStorageWithOSS03 OSS だけでスケーラブルなストレージを安価に構築する方法 #3]
* [wiki:ScalableStorageWithOSS04 OSS だけでスケーラブルなストレージを安価に構築する方法 #4]
* [wiki:ScalableStorageWithOSS05 OSS だけでスケーラブルなストレージを安価に構築する方法 #5]
