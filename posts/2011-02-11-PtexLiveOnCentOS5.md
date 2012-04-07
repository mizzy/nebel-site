---
layout: post
title: PtexLiveOnCentOS5
date: 2011-02-11 11:31:55 +0900
---


ptexlive のビルドに必要なパッケージインストール用 Puppet マニフェスト

	
	package {
	  'xz':
	    ensure => present;
	  'libXt-devel':
	    ensure => present;
	  'libXaw-devel':
	    ensure => present;
	  'gcc':
	    ensure => present;
	  'make':
	    ensure => present;
	  'gcc-c++':
	    ensure => present;
	  'fontconfig-devel':
	    ensure => present;
	  'ghostscript':
	    ensure => present;
	}
	

ビルド＆インストール用シェルスクリプト

	
	#!sh
	#!/bin/sh
	
	wget ftp://tug.org/historic/systems/texlive/2009/texlive2009-20091107.iso.xz
	unxz texlive2009-20091107.iso.xz
	
	mount -o loop texlive2009-20091107.iso /mnt
	
	cd /mnt
	
	./install-tl
	
	cd
	
	wget http://tutimura.ath.cx/~nob/tex/ptexlive/ptexlive-20100711.tar.gz
	tar zxvf ptexlive-20100711.tar.gz
	
	cd ptexlive-20100711
	cp ptexlive.sample ptexlive.cfg
	
	sed -i 's!ISO_DIR=/media/TeXLive2009!ISO_DIR=/mnt!g' ptexlive.cfg
	sed -i 's!# conf_option --without-x!conf_option --without-x!g' ptexlive.cfg
	sed -i 's!# conf_option --disable-xdvik!conf_option --disable-xdvik!g' ptexlive.cfg
	sed -i 's!# conf_option --disable-pxdvik!conf_option --disable-pxdvik!g' ptexlive.cfg
	sed -i 's!# XDVI=echo!XDVI=echo!g' ptexlive.cfg
	
	sed -i 's/grep "recursive calls"/grep "Loop in Pages tree"/g' 8test.sh
	
	yes yes | make
	
	make install
	
