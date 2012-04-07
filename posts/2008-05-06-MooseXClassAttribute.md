---
layout: post
title: MooseXClassAttribute
date: 2008-05-06 13:05:43 +0900
---


流行に乗って [Punc](http://coderepos.org/share/wiki/Punc) にも Moose を取り入れようと思って、MooseX::ClassAttribute でクラス属性をハンドリングできるようにしてみたのですが、子クラスのクラス属性をセットすると、親クラスのクラス属性まで変わってしまう。

	
	#!perl
	#!/usr/bin/perl
	
	package Parent;
	use Moose;
	use MooseX::ClassAttribute;
	
	class_has 'x' => ( is => 'rw' );
	
	package Child;
	use Moose;
	extends 'Parent';
	
	package main;
	
	Parent->x('Parent');
	warn Parent->x; # Parent が表示される
	
	Child->x('Child');
	warn Parent->x; # Child が表示されてしまう
	

これが一般的に望ましい動作なのかどうかわからないので、とりあえず Class::Data::Inheritable 使うように書き直した。