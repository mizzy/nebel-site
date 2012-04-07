---
layout: post
title: UfwOnCentOS5
date: 2011-05-27 01:05:06 +0900
---

[tokuhirom](http://d.hatena.ne.jp/tokuhirom/) さんが IRC で「[ufw](https://launchpad.net/ufw) べんり！」「iptables より簡単」っておっしゃっていて、日頃から iptables のコマンドインターフェースは最悪だと思っていたので、お、それは試してみたい、ってことで、ちょろっと触ってみました。

ufw って Ubuntu に標準で付属してるんですね。Ubuntu 使ってないんで知りませんでした。で、ufw の u は Ubuntu の u なのかな、と思ったら、Uncomplicated Firewall の略だそうで、だったら普段一番使ってる CentOS5 でも動くかも、と思って、パッケージ作ったり軽く動かしたりしてみたんで、その記録です。（CentOS の今後については色々言われてますが、まあそこは気にせずに。）

まず RPM パッケージをつくろう、ってことで、ググったら [ufw.spec](http://www.openmamba.org/pub/openmamba/devel-ercolinux/specs/ufw.spec) を見つけたので、これを CentOS5 で動くようにカスタマイズして、[ソース RPM](http://svn.mizzy.org/public/yum/SRPMS/ufw-0.30.1-1.src.rpm) と [バイナリ RPM](http://svn.mizzy.org/public/yum/RPMS/centos/5/x86_64/RPMS/ufw-0.30.1-1.x86_64.rpm) を作成。ufw は python 2.5 以降が必要なんですが、CentOS5 デフォルトは 2.4 なので、python26 パッケージが必要です。あと、spec のカスタマイズも超適当だけど気にしないでください。

で、パッケージインストール後、iptables が動いてない状態から、ufw enable して iptables -L -n してみたら、以下のようにルールが設定されていた。

	
	$ sudo /usr/sbin/ufw enable
	Password: 
	Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
	Firewall is active and enabled on system startup
	
	$ sudo /sbin/iptables -L -n
	Chain INPUT (policy DROP)
	target     prot opt source               destination         
	ufw-before-logging-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-before-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-logging-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-reject-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-track-input  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain FORWARD (policy DROP)
	target     prot opt source               destination         
	ufw-before-logging-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-before-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-logging-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-reject-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain OUTPUT (policy ACCEPT)
	target     prot opt source               destination         
	ufw-before-logging-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-before-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-logging-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-reject-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-track-output  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-after-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-after-input (1 references)
	target     prot opt source               destination         
	ufw-skip-to-policy-input  udp  --  0.0.0.0/0            0.0.0.0/0           udp dpt:137 
	ufw-skip-to-policy-input  udp  --  0.0.0.0/0            0.0.0.0/0           udp dpt:138 
	ufw-skip-to-policy-input  tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:139 
	ufw-skip-to-policy-input  tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:445 
	ufw-skip-to-policy-input  udp  --  0.0.0.0/0            0.0.0.0/0           udp dpt:67 
	ufw-skip-to-policy-input  udp  --  0.0.0.0/0            0.0.0.0/0           udp dpt:68 
	ufw-skip-to-policy-input  all  --  0.0.0.0/0            0.0.0.0/0           ADDRTYPE match dst-type BROADCAST 
	
	Chain ufw-after-logging-forward (1 references)
	target     prot opt source               destination         
	LOG        all  --  0.0.0.0/0            0.0.0.0/0           limit: avg 3/min burst 10 LOG flags 0 level 4 prefix `[UFW BLOCK] ' 
	
	Chain ufw-after-logging-input (1 references)
	target     prot opt source               destination         
	LOG        all  --  0.0.0.0/0            0.0.0.0/0           limit: avg 3/min burst 10 LOG flags 0 level 4 prefix `[UFW BLOCK] ' 
	
	Chain ufw-after-logging-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-after-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-forward (1 references)
	target     prot opt source               destination         
	ufw-user-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-before-input (1 references)
	target     prot opt source               destination         
	ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
	ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED 
	ufw-logging-deny  all  --  0.0.0.0/0            0.0.0.0/0           state INVALID 
	DROP       all  --  0.0.0.0/0            0.0.0.0/0           state INVALID 
	ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           icmp type 3 
	ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           icmp type 4 
	ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           icmp type 11 
	ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           icmp type 12 
	ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           icmp type 8 
	ACCEPT     udp  --  0.0.0.0/0            0.0.0.0/0           udp spt:67 dpt:68 
	ufw-not-local  all  --  0.0.0.0/0            0.0.0.0/0           
	ACCEPT     udp  --  0.0.0.0/0            224.0.0.251         udp dpt:5353 
	ufw-user-input  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-before-logging-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-logging-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-logging-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-output (1 references)
	target     prot opt source               destination         
	ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
	ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED 
	ufw-user-output  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-logging-allow (0 references)
	target     prot opt source               destination         
	LOG        all  --  0.0.0.0/0            0.0.0.0/0           limit: avg 3/min burst 10 LOG flags 0 level 4 prefix `[UFW ALLOW] ' 
	
	Chain ufw-logging-deny (2 references)
	target     prot opt source               destination         
	RETURN     all  --  0.0.0.0/0            0.0.0.0/0           state INVALID limit: avg 3/min burst 10 
	LOG        all  --  0.0.0.0/0            0.0.0.0/0           limit: avg 3/min burst 10 LOG flags 0 level 4 prefix `[UFW BLOCK] ' 
	
	Chain ufw-not-local (1 references)
	target     prot opt source               destination         
	RETURN     all  --  0.0.0.0/0            0.0.0.0/0           ADDRTYPE match dst-type LOCAL 
	RETURN     all  --  0.0.0.0/0            0.0.0.0/0           ADDRTYPE match dst-type MULTICAST 
	RETURN     all  --  0.0.0.0/0            0.0.0.0/0           ADDRTYPE match dst-type BROADCAST 
	ufw-logging-deny  all  --  0.0.0.0/0            0.0.0.0/0           limit: avg 3/min burst 10 
	DROP       all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-reject-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-reject-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-reject-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-skip-to-policy-forward (0 references)
	target     prot opt source               destination         
	DROP       all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-skip-to-policy-input (7 references)
	target     prot opt source               destination         
	DROP       all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-skip-to-policy-output (0 references)
	target     prot opt source               destination         
	ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-track-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-track-output (1 references)
	target     prot opt source               destination         
	ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW 
	ACCEPT     udp  --  0.0.0.0/0            0.0.0.0/0           state NEW 
	
	Chain ufw-user-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-user-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-user-limit (0 references)
	target     prot opt source               destination         
	LOG        all  --  0.0.0.0/0            0.0.0.0/0           limit: avg 3/min burst 5 LOG flags 0 level 4 prefix `[UFW LIMIT BLOCK] ' 
	REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 
	
	Chain ufw-user-limit-accept (0 references)
	target     prot opt source               destination         
	ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-user-logging-forward (0 references)
	target     prot opt source               destination         
	
	Chain ufw-user-logging-input (0 references)
	target     prot opt source               destination         
	
	Chain ufw-user-logging-output (0 references)
	target     prot opt source               destination         
	
	Chain ufw-user-output (1 references)
	target     prot opt source               destination         
	

で、今度は ufw disable してみたら、以下のようになった。chain は残る模様。

	
	$ sudo /usr/sbin/ufw disable
	Firewall stopped and disabled on system startup
	
	$ sudo /sbin/iptables -L -n
	Chain INPUT (policy ACCEPT)
	target     prot opt source               destination         
	ufw-before-logging-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-before-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-logging-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-reject-input  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-track-input  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain FORWARD (policy ACCEPT)
	target     prot opt source               destination         
	ufw-before-logging-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-before-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-logging-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-reject-forward  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain OUTPUT (policy ACCEPT)
	target     prot opt source               destination         
	ufw-before-logging-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-before-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-after-logging-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-reject-output  all  --  0.0.0.0/0            0.0.0.0/0           
	ufw-track-output  all  --  0.0.0.0/0            0.0.0.0/0           
	
	Chain ufw-after-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-after-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-after-logging-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-after-logging-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-after-logging-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-after-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-logging-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-logging-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-logging-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-before-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-reject-forward (1 references)
	target     prot opt source               destination         
	
	Chain ufw-reject-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-reject-output (1 references)
	target     prot opt source               destination         
	
	Chain ufw-track-input (1 references)
	target     prot opt source               destination         
	
	Chain ufw-track-output (1 references)
	target     prot opt source               destination         
	

とりあえず CentOS5 でも動くようなんで、色々遊んでみようと思う。