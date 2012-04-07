---
layout: post
title: ScalableStorageWithOSS00
date: 2008-12-28 17:21:10 +0900
---


[TLUG Meeting 2008/09 で発表した How to build a scalable storage system with OSS](http://trac.mizzy.org/public/wiki/HowToBuildAScalableStorageSystemWithOSS) なんですが、発表では概要しか触れてなくて、じゃあいったいどうやって構築するのよ、という部分が全然ないので、ぼちぼちこのブログで書いていくことにします。

で、スケーラブルというだけだと曖昧なので、以下のような要件を満たすものを、スケーラブルなストレージと想定することにします。

* 特殊なソフトウェアを必要とせずに、OS からファイルシステムとしてマウントできるもの。なので MogileFS、Hadoop Distributed File System、Google File System 等は対象外。（FUSE 使えばやれないこともないけど…）
* 容量をオンラインでダイナミックに追加できる。
* SPOF がない。
* 複数のサーバから同時にマウントすることができる。
* 物理的に I/O を柔軟に分散することができる。
* 無駄な空きスペースができにくい。

で、こういったストレージを、高価なハードウェアを買わずに、オープンソースソフトウェアだけで構築することができないか、と考えて、こんな感じで実現できそうだなあー、というのを発表したのが TLUG でのプレゼンの内容。このプレゼンで出てきたキーワードとその概要をおさらいすると、以下のような感じ。

* [cman](http://sources.redhat.com/cluster/cman/)
   * Cluster Manager
   * Red Hat Cluster Suite の一コンポーネント
   * クラスタのメンバーシップ管理とノード間のメッセージング
   * 以下に出てくる、CLVM や GFS2 を使うために必要
* [CLVM](http://sources.redhat.com/cluster/clvm/)
   * Cluster Logical Volume Manager
   * LVM2 のクラスタ版
   * LVM2 のメタデータをクラスタノード間で自動的にシェアする
   * CLVM で作成された論理ボリュームは、すべてのクラスタノードから参照できる
* [GNBD](http://sourceware.org/cluster/gnbd/)
   * Global Network Block Device
   * TCP/IP ネットワーク経由でのブロックデバイスアクセス
   * iSCSI と同じようなもの
   * iSCSI との違いは、フェンシング機能を持っていること（フェンシングについては機会があれば説明します）
* [GFS2](http://sources.redhat.com/cluster/gfs/)
   * Global File System 2
   * クラスタファイルシステム
   * 複数ノードから同時にマウントしてアクセスすることが可能
   * cman の DLM(Distributed Lock Manager) を利用して排他制御し、ファイルの整合性を保つ
   * OCFS(Oracle Cluster File System) なんかも同類
* [DRBD](http://www.drbd.org/)
   * Ditributed Replicated Block Device
   * 要するにネットワーク越しの RAID1
* [DM-MP](http://www.redhat.com/docs/manuals/csgfs/browse/4.6/DM_Multipath/index.html)
   * Device-Mapper Multipath
   * 複数の I/O 経路を仮想的にひとつに見せかけることができる
   * Active/Passive、Active/Active どちらでも対応可

[TLUG での発表資料](http://www.slideshare.net/mizzy/how-to-build-a-scalable-storage-system-at-tlug-meeting-20080913-presentation) では、それぞれを図で説明していたり、これらをどう組み合わせて利用するのかを説明しているので、ご参照ください。

で、これらを組み合わせて構築したストレージがとりあえず動くことは確認できたのだけど、実用に耐えうるかどうかは謎。特に以下の点が気になるところ。

* 協調動作するコンポーネントが多くて、トラブルが起こりやすそう。
* 安定性。
* パフォーマンス。
* ストレージとなるサーバを追加して容量を増やした場合のオーバーヘッドの増加具合。

なので、今後実際に使うかどうかはまだ決めかねてるのですが、一通り動かせるところまでは試してみたので、次回から実際の構築手順を書いていこうと思います。

# 関連エントリ

* [wiki:ScalableStorageWithOSS01 OSS だけでスケーラブルなストレージを安価に構築する方法 #1]
* [wiki:ScalableStorageWithOSS02 OSS だけでスケーラブルなストレージを安価に構築する方法 #2]
* [wiki:ScalableStorageWithOSS03 OSS だけでスケーラブルなストレージを安価に構築する方法 #3]
* [wiki:ScalableStorageWithOSS04 OSS だけでスケーラブルなストレージを安価に構築する方法 #4]
* [wiki:ScalableStorageWithOSS05 OSS だけでスケーラブルなストレージを安価に構築する方法 #5]
