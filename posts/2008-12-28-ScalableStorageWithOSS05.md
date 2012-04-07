---
layout: post
title: ScalableStorageWithOSS05
date: 2008-12-28 17:20:40 +0900
---


ずいぶん間があいちゃいましたが、[wiki:ScalableStorageWithOSS04 OSS だけでスケーラブルなストレージを安価に構築する方法 #4] のつづき。今回は DM-MP により束ねられた仮想的なブロックデバイス（/dev/mapper/mpath0 と /dev/mapper/mpath1）を、更に CLVM でひとつの論理ボリュームにし、GFS2 でフォーマットした後、実際にマウントしてみます。今回が最終回です。


# CLVM のインストールと設定

client0, client1 双方でインストールと設定。

	
	$ sudo yum -y install lvm2-cluster
	

/etc/lvm/lvm.conf を編集し、locking_type を 3 に設定。

	
	locking_type = 3 
	

clvmd を起動。

	
	$ sudo /etc/init.d/clvmd start
	

# 物理ボリューム/ボリュームグループ/論理ボリュームの作成

通常の LVM と同様に、物理ボリューム/ボリュームグループ/論理ボリュームを作成。これは client0 上だけで行う。通常の LVM と異なるのは、vgcreate で --clustered y を指定すること。

	
	$ sudo /usr/sbin/pvcreate /dev/mapper/mpath0
	$ sudo /usr/sbin/pvcreate /dev/mapper/mpath1
	$ sudo /usr/sbin/vgcreate --clustered y VG0 /dev/mapper/mpath0 /dev/mapper/mpath1
	$ sudo /usr/sbin/lvcreate --extent=510 --name=LV0 VG0 
	

pvdisplay, vgdisplay, lvdisplay で確認。

	
	# pvdisplay
	  --- Physical volume ---
	  PV Name               /dev/dm-0
	  VG Name               VG0
	  PV Size               1023.90 MB / not usable 3.90 MB
	  Allocatable           yes (but full)
	  PE Size (KByte)       4096
	  Total PE              255
	  Free PE               0
	  Allocated PE          255
	  PV UUID               8Whtgb-7jrP-4M24-AMmB-aqA3-VQ8G-iSvijF
	
	  --- Physical volume ---
	  PV Name               /dev/dm-1
	  VG Name               VG0
	  PV Size               1023.90 MB / not usable 3.90 MB
	  Allocatable           yes (but full)
	  PE Size (KByte)       4096
	  Total PE              255
	  Free PE               0
	  Allocated PE          255
	  PV UUID               RC8J4S-hCRI-IlmJ-DqKB-Lk06-6Pza-nke5f8
	

	
	# vgdisplay
	  --- Volume group ---
	  VG Name               VG0
	  System ID
	  Format                lvm2
	  Metadata Areas        2
	  Metadata Sequence No  2
	  VG Access             read/write
	  VG Status             resizable
	  Clustered             yes
	  Shared                no
	  MAX LV                0
	  Cur LV                1
	  Open LV               1
	  Max PV                0
	  Cur PV                2
	  Act PV                2
	  VG Size               1.99 GB
	  PE Size               4.00 MB
	  Total PE              510
	  Alloc PE / Size       510 / 1.99 GB
	  Free  PE / Size       0 / 0
	  VG UUID               XPwKeu-5lDP-9eCv-gUoC-HIB0-ItMV-4bxRHN 
	

	
	sudo /usr/sbin/lvdisplay
	  --- Logical volume ---
	  LV Name                /dev/VG0/LV0
	  VG Name                VG0
	  LV UUID                PYScA4-OeAf-Dndj-5hMW-4a0x-Yfaj-6zIYpE
	  LV Write Access        read/write
	  LV Status              available
	  # open                 0
	  LV Size                1.99 GB
	  Current LE             510
	  Segments               2
	  Allocation             inherit
	  Read ahead sectors     auto
	  - currently set to     256
	  Block device           253:2  
	

client1 でも lvdisplay で論理ボリュームが見えるかを確認。

	
	sudo /usr/sbin/lvdisplay
	  --- Logical volume ---
	  LV Name                /dev/VG0/LV0
	  VG Name                VG0
	  LV UUID                PYScA4-OeAf-Dndj-5hMW-4a0x-Yfaj-6zIYpE
	  LV Write Access        read/write
	  LV Status              available
	  # open                 0
	  LV Size                1.99 GB
	  Current LE             510
	  Segments               2
	  Allocation             inherit
	  Read ahead sectors     auto
	  - currently set to     256
	  Block device           253:2  
	



# GFS2でフォーマットしてマウント

client0, client1 両方に gfs2-utils パッケージをインストール。

	
	$ sudo yum -y install gfs2-utils
	

client0 上だけで、mkfs2.gfs2 を実行してフォーマットする。

	
	$ sudo /sbin/mkfs.gfs2 -p lock_dlm -t client:gfs2 -j 4 /dev/VG0/LV0
	This will destroy any data on /dev/VG0/LV0.
	
	Are you sure you want to proceed? [y/n] y 
	
	Device:                    /dev/VG0/LV0
	Blocksize:                 4096
	Device Size                1.99 GB (522240 blocks)
	Filesystem Size:           1.99 GB (522240 blocks)
	Journals:                  4
	Resource Groups:           8
	Locking Protocol:          "lock_dlm"
	Lock Table:                "client:gfs2"
	

client0, client1 両方でマウント。

	
	$ sudo mount /dev/VG0/LV0 /mnt  
	

client0 上でファイルをつくると、client1 でも見えることを確認。

	
	client0$ sudo touch /mnt/ieiri
	

	
	client1$ ls /mnt
	ieiri
	

これで完了。現在の状態を図にすると、以下のような感じで、4台のサーバに分散されたブロックデバイスがひとつの論理ボリュームとして見え、更に複数のマシンから同時にマウントできている。

[[Image(http://trac.mizzy.org/public/attachment/wiki/ScalableStorageWithOSS01/scalable_storage.jpg?format=raw)]]


# 最後に

本当はここから更に、ダイナミックにストレージサーバを追加して容量を拡張する手順なんかも書きたいところなんですが、[wiki:ScalableStorageWithOSS00 #0] でも書いたような、以下の懸念点があるため、今のところ実用で使おうとは考えていません。

* 協調動作するコンポーネントが多くて、トラブルが起こりやすそう。
   * 実際に各コンポーネントを起動/停止する順を間違えると、ハングアップしたりする。
   * 低レイヤーなだけに、トラブルが起きたときの対応がとても難しそう。
* 安定性。
* パフォーマンス。
* ストレージとなるサーバを追加して容量を増やした場合のオーバーヘッドの増加具合。

というわけで、これ以上踏む込むことは今のところやめておきます。まずはこんな技術があるんだ、ということを知って、動くところまで試しただけでも、自分にとっては十分収穫があったな、と。


# 関連エントリ

* [wiki:ScalableStorageWithOSS00 OSS だけでスケーラブルなストレージを安価に構築する方法 #0]
* [wiki:ScalableStorageWithOSS01 OSS だけでスケーラブルなストレージを安価に構築する方法 #1]
* [wiki:ScalableStorageWithOSS02 OSS だけでスケーラブルなストレージを安価に構築する方法 #2]
* [wiki:ScalableStorageWithOSS03 OSS だけでスケーラブルなストレージを安価に構築する方法 #3]
* [wiki:ScalableStorageWithOSS04 OSS だけでスケーラブルなストレージを安価に構築する方法 #4]
