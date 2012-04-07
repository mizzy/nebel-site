---
layout: post
title: KvmOnCentOS54
date: 2009-10-31 11:40:59 +0900
---


CentOS 5.4 から KVM が正式にサポートされたようなので、試してみた。

# KVM が動く環境をつくる


まずは既存の 5.3 環境から 5.4 にアップグレード。

	
	$ sudo yum -y upgrade
	

不要になった kernel-xen は削除。

	
	$ sudo yum -y remove kernel-xen
	

kmod-kvm, kvm をインストール。

	
	$ sudo yum -y install kmod-kvm kvm
	

/boot/grub/menu.lst 修正。

	
	title CentOS (2.6.18-164.el5)
		root (hd0,0)
		kernel /vmlinuz-2.6.18-164.el5 ro root=/dev/vg00/lv_root vga=773
		initrd /initrd-2.6.18-164.el5.img
	

再起動する。


# Cobbler + Koan での VM 作成

今まで Xen をつかっていて、Cobbler + Koan で VM をつくっていたが、KVM でも同じ手順でできるはず、ってことで koan コマンド実行してみた。

	
	$ sudo koan --server localhost --virt --profile=FC11-x86_64 --virt-name=fc11-kvm
	- looking for Cobbler at http://localhost/cobbler_api
	- reading URL: http://192.168.10.11/cblr/svc/op/ks/profile/FC11-x86_64
	install_tree: http://192.168.10.11:80/cblr/links/FC11-x86_64
	libvirtd (pid  3681) is running...
	- using qemu hypervisor, type=kvm
	Fri, 30 Oct 2009 17:37:07 DEBUG    No conn passed to Guest, opening URI 'qemu:///system'
	Fri, 30 Oct 2009 17:37:07 DEBUG    DistroInstaller location is a network source.
	libvir: QEMU error : Domain not found: no domain with matching name 'fc11-kvm'
	- adding disk: /opt/qemu//fc11-kvm-disk0 of size 5
	
	... 中略 ...
	
	libvir: QEMU error : internal error Failed to add tap interface 'vnet%d' to bridge 'xenbr0' : No such device
	
	... 以下略 ...
	

type=kvm と表示されているので、KVM が使われているようだが、エラーに。

Xen ではないため、xenbr0 が存在しないが、Xen の時の設定が Cobbler に残っていた。

libvirt が生成する virbr0 というブリッジインターフェースが存在するが、外部との接続ができないようなので、新たにブリッジインターフェースを作成することにした。

まずは /etc/sysconfig/network-scripts/ifcfg-br0 を作成。

	
	DEVICE=br0
	TYPE=Bridge
	BOOTPROTO=dhcp
	ONBOOT=yes
	

/etc/sysconfig/network-scripts/ifcfg-eth0 に以下を追加。

	
	BRIDGE=br0
	

ネットワーク再起動する。

	
	$ sudo /etc/init.d/network restart
	

これで br0 ができるので、br0 を使うように cobbler コマンドで設定する。

	
	$ sudo cobbler profile edit --name=FC11-x86_64 --virt-bridge=br0
	

ついでに、CUI からコンソール接続できるように、この profile で利用している /var/lib/cobbler/kickstarts/sample.ks の bootloader 行を以下のように修正。

	
	bootloader --location=mbr --append="console=tty0 console=ttyS0,115200"
	

再度 koan を実行して VM 作成。

	
	$ sudo koan --server localhost --virt --profile=FC11-x86_64 --virt-name=fc11-kvm
	

状態確認。

	
	$ sudo virsh list --all                                            
	 Id Name                 State
	----------------------------------
	 10 fc11-kvm             running
	

インストールが終わると、shut off になる。

	
	$ sudo virsh list --all
	 Id Name                 State
	----------------------------------
	  - fc11-kvm             shut off
	

起動する。

	
	$ sudo virsh start fc11-kvm
	

コンソール接続してみる。

	
	$ sudo virsh console fc11-kvm
	Connected to domain fc11-kvm
	Escape character is ^]
	?G		Welcome to Fedora 
			Press 'I' to enter interactive startup.
	Starting udev: G[  OK  ]
	Setting hostname h029.southpark:  [  OK  ]
	mdadm: No arrays found in config file or automatically
	Setting up Logical Volume Management:   2 logical volume(s) in volume group "vg_h029" now active
	
	... 中略 ...
	
	Fedora release 11 (Leonidas)
	Kernel 2.6.29.4-167.fc11.x86_64 on an x86_64 (/dev/ttyS0)
	
	h029.southpark login: 
	

# ディスク追加してみる

イメージファイル作成。

	
	$ sudo qemu-img create /opt/qemu/fc11-kvm-disk1 8G
	

disk.xml を以下の内容で作成。

	
	<disk type='file' device='disk'>
	  <source file='/opt/qemu/fc11-kvm-disk1'/>
	  <target dev='vdb' bus='virtio' />
	</disk>
	

追加する。

	
	$ sudo virsh attach-device fc11-kvm disk.xml
	Device attached successfully
	

これで /dev/vdb が VM から見えるようになる。
