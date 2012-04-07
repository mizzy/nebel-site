---
layout: post
title: HowToGetGraphiteWorkingOnScientificLinux6
date: 2011-07-24 23:18:15 +0900
---


I found a interest tool, [Graphite](http://graphite.wikidot.com/) when I was exploring https://github.com/etsy .([Screen Shots of Graphite](http://graphite.wikidot.com/screen-shots).)

# Install Carbon

[Carbon](http://graphite.wikidot.com/carbon) is a backend storage application for Graphite.

	
	# wget http://launchpad.net/graphite/1.0/0.9.8/+download/carbon-0.9.8.tar.gz
	# tar zxvf carbon-0.9.8.tar.gz
	# pushd carbon-0.9.8
	# python setup.py install
	# popd
	

# Install Whisper

[Whisper](http://graphite.wikidot.com/whisper) is an alternate to RRD.


	
	# wget http://launchpad.net/graphite/1.0/0.9.8/+download/whisper-0.9.8.tar.gz
	# tar zxvf whisper-0.9.8.tar.gz
	# pushd whisper-0.9.8
	# python setup.py install
	# popd
	


# Install Graphite

	
	# wget http://launchpad.net/graphite/1.0/0.9.8/+download/graphite-web-0.9.8.tar.gz
	# tar zxvf graphite-web-0.9.8.tar.gz
	# pushd graphite-web-0.9.8      
	

Run check-dependencies.py.

	
	# ./check-dependencies.py 
	[FATAL] Unable to import the 'cairo' module, do you have pycairo installed for python 2.6.5?
	[FATAL] Unable to import the 'django' module, do you have Django installed for python 2.6.5?
	[WARNING] Unable to import the 'mod_python' module, do you have mod_python installed for python 2.6.5?
	This means you will only be able to run graphite in the development server mode, which is not
	recommended for production use.
	[WARNING]
	Unable to import the 'memcache' module, do you have python-memcached installed for python 2.6.5?
	This feature is not required but greatly improves performance.
	
	[WARNING]
	Unable to import the 'ldap' module, do you have python-ldap installed for python 2.6.5?
	Without python-ldap, you will not be able to use LDAP authentication in the graphite webapp.
	
	[WARNING]
	Unable to import the 'twisted' package, do you have Twisted installed for python 2.6.5?
	Without Twisted, you cannot run carbon on this server.
	[WARNING]
	Unable to import the 'txamqp' module, this is required if you want to use AMQP.
	Note that txamqp requires python 2.5 or greater.
	2 necessary dependencies not met. Graphite will not function until these dependencies are fulfilled.
	5 optional dependencies not met. Please consider the warning messages before proceeding.
	

I use a development server included in Graphite, so mod_python is not needed.

Install packages other than mod_python.

	
	# yum install pycairo
	# rpm -ivh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-5.noarch.rpm
	# yum install Django python-twisted python-memcached python-ldap
	# yum install python-setuptools gcc python-devel
	# easy_install txamqp
	

You need bitmap fonts, so intall it.

	
	# yum install bitmap-console-fonts
	


Install Graphite and setup it.

	
	# python setup.py install
	# python /opt/graphite/webapp/graphite/manage.py syncdb
	# pushd /opt/graphite/conf
	# cp carbon.conf.example carbon.conf
	# cp storage-schemas.conf.example storage-schemas.conf
	# cp dashboard.conf.example dashboard.conf
	

Edit dashborad.conf and uncomment these.

	
	[ui]
	default_graph_width = 400
	default_graph_height = 250
	automatic_variants = true
	refresh_interval = 60
	

Start Carbon.

	
	# /opt/graphite/bin/carbon-cache.py start
	

Start example-client included in Graphite source code to send load average data to Carbon.

	
	# popd
	# python ./examples/example-client.py
	

Start a develepment server of Graphite.

	
	# /opt/graphite/bin/run-graphite-devel-server.py /opt/graphite  
	

Access to port 8080 of this server and you'll see the screen of Graphite.
