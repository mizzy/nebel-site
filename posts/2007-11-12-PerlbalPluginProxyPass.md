---
layout: post
title: PerlbalPluginProxyPass
date: 2007-11-12 00:15:48 +0900
---


Perlbal で Vpaths プラグインをつかって、

	
	LOAD vpaths
	
	CREATE POOL apache
	  POOL apache ADD 127.0.0.1
	
	CREATE SERVICE apache_proxy
	  SET role = reverse_proxy
	  SET pool = apache
	ENABLE apache_proxy
	
	CREATE SERVICE selector
	  SET   listen  = 0.0.0.0:8080
	  SET   role    = selector
	  SET   plugins = vpaths
	  VPATH /apache = apache_proxy
	ENABLE selector
	

みたいな設定をすると、

	
	http://localhost:8080/apache -> http://localhost:80/apache
	

といった形でプロキシしてくれるんだけど、これを

	
	http://localhost:8080/apache -> http://localhost:80/
	

としたくてプラグイン書いてみた。もしかしてプラグイン書かなくてもできるかもしれないけど、やり方がわからなかったのと、プラグインを書く練習ってことで。プラグイン名は Apache mod_proxy の ProxyPass ディレクティブにちなんでます。

	
	#!perl
	package Perlbal::Plugin::ProxyPass;
	
	use strict;
	use warnings;
	
	sub load {
	    my $class = shift;
	
	    Perlbal::register_global_hook('manage_command.proxypass', sub {
	        my $mc = shift->parse(qr/proxypass\s+(?:(\w+)\s+)?(\S+)\s*=\s*(\S+)$/,
	                              "usage: ProxyPass [<service>] <source path> = <dest path>");
	        my ($selname, $source, $target) = $mc->args;
	        unless ($selname ||= $mc->{ctx}{last_created}) {
	            return $mc->err("omitted service name not implied from context");
	        }
	
	        my $ss = Perlbal->service($selname);
	        return $mc->err("Service '$selname' is not a reverse_proxy service")
	            unless $ss && $ss->{role} eq "reverse_proxy";
	
	        $ss->{extra_config}->{_proxypass} ||= [];
	        push @{$ss->{extra_config}->{_proxypass}}, [ $source, $target ];
	
	        return $mc->ok;
	    });
	
	    return 1;
	}
	
	sub register {
	    my ($class, $svc) = @_;
	    unless ($svc && $svc->{role} eq "reverse_proxy") {
	        die "You can't load the proxypass plugin on a service not of role reverse_proxy.\n";
	    }
	
	    $svc->register_hook(
	        'ProxyPass' => 'start_proxy_request', sub {
	            my Perlbal::ClientProxy $client = shift;
	            for my $proxypass ( @{ $svc->{extra_config}->{_proxypass} } ) {
	                my $source = $proxypass->[0];
	                my $target = $proxypass->[1];
	                $client->{req_headers}->{uri} =~ s/$source/$target/;
	                $client->{req_headers}->{uri} =~ s!//!/!;
	            }
	            return 0;
	        }
	    );
	
	    return 1;
	}
	
	1;
	

設定はこんな感じ。

	
	LOAD vpaths
	LOAD ProxyPass
	
	CREATE POOL apache
	  POOL apache ADD 127.0.0.1
	
	CREATE SERVICE apache_proxy
	  SET       role    = reverse_proxy
	  SET       pool    = apache
	  SET       plugins = ProxyPass
	  ProxyPass /apache = /   
	ENABLE apache_proxy
	
	CREATE SERVICE selector
	  SET   listen  = 0.0.0.0:8080
	  SET   role    = selector
	  SET   plugins = vpaths
	  VPATH /apache = apache_proxy
	ENABLE selector
	