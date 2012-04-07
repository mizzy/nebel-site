---
layout: post
title: LinuxContainer00
date: 2011-07-17 16:33:08 +0900
---


# Make and install lxc rpm packages

The spec file for lxc is included in lxc source code.So you can make rpm packages of lxc easily.

	
	# yum -y update kernel
	# reboot
	# yum -y install rpm-build libcap-devel docbook-utils kernel-devel gcc make
	# wget http://lxc.sourceforge.net/download/lxc/lxc-0.7.4.2.tar.gz
	# tar zxvf lxc-0.7.4.2.tar.gz
	# mkdir -p ~/rpmbuild/SOURCES
	# cp lxc-0.7.4.2.tar.gz ~/rpmbuild/SOURCES
	# chown root:root lxc-0.7.4.2/lxc.spec
	# rpmbuild -ba lxc-0.7.4.2/lxc.spec --define 'ksrc /usr/src/kernels/`uname -r`'
	# rpm -Uvh ~/rpmbuild/RPMS/x86_64/lxc-0.7.4.2-1.x86_64.rpm
	

----

# Check whether this os is lxc ready or not

All statuses should be "enabled".

	
	# lxc-checkconfig 
	Kernel config /proc/config.gz not found, looking in other places...
	Found kernel config file /boot/config-2.6.32-131.2.1.el6.x86_64
	--- Namespaces ---
	Namespaces: enabled
	Utsname namespace: enabled
	Ipc namespace: enabled
	Pid namespace: enabled
	User namespace: enabled
	Network namespace: enabled
	Multiple /dev/pts instances: enabled
	
	--- Control groups ---
	Cgroup: enabled
	Cgroup namespace: enabled
	Cgroup device: enabled
	Cgroup sched: enabled
	Cgroup cpu account: enabled
	Cgroup memory controller: enabled
	Cgroup cpuset: enabled
	
	--- Misc ---
	Veth pair device: enabled
	Macvlan: enabled
	Vlan: enabled
	File capabilities: enabled
	enabled
	


----

# Quick Start

In the man of lxc, you can get how to start lxc quickly.

	
	QUICK START
	       You are in a hurry, and you don’t want to read this man page. Ok, with-
	       out warranty, here are the commands to launch a  shell  inside  a  con-
	       tainer   with   a  predefined  configuration  template,  it  may  work.
	       /usr/bin/lxc-execute -n foo -f /usr/share/doc/lxc/examples/
	       lxc-macvlan.conf /bin/bash
	

But before running lxc-execute, you should mount croup.

	
	# mount -t cgroup cgroup /cgroup
	# /usr/bin/lxc-execute -n foo -f /usr/share/doc/lxc/examples/lxc-macvlan.conf /bin/bash
	

In the container, processes are like this.

	
	# ps -ef
	UID        PID  PPID  C STIME TTY          TIME CMD
	root         1     0  0 10:54 ttyS0    00:00:00 /usr/lib64/lxc/lxc-init -- /bin/
	root         2     1  0 10:54 ttyS0    00:00:00 /bin/bash
	root        11     2  0 10:55 ttyS0    00:00:00 ps -ef
	

You can also see the processes in the container from the outside of the container.

	
	# lxc-ps --name=foo
	CONTAINER    PID TTY          TIME CMD
	foo         1654 ttyS0    00:00:00 lxc-init
	foo         1656 ttyS0    00:00:00 bash
	

The sample lxc conf is like this.

	
	# cat /usr/share/doc/lxc/examples/lxc-macvlan.conf 
	# Container with network virtualized using the macvlan device driver
	lxc.utsname = alpha
	lxc.network.type = macvlan
	lxc.network.flags = up
	lxc.network.link = eth0
	lxc.network.hwaddr = 4a:49:43:49:79:bd
	lxc.network.ipv4 = 1.2.3.4/24
	lxc.network.ipv6 = 2003:db8:1:0:214:1234:fe0b:3596
	

