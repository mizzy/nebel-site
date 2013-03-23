---
title: Create LXC system containers easily with Puppet
date: 2013-03-24 01:47:23 +0900
---
## Overview

I'm refactoring [Puppet](https://puppetlabs.com/) manifests and refactoring requires automated testing.

[rspec-puppet](http://rspec-puppet.com/) and [cucumber-puppet](http://projects.puppetlabs.com/projects/cucumber-puppet/wiki) test Puppet catalog, but I need to test actual server status that Puppet manifests applied to.

For actual testing, several virtual machines are needed. [Vagrant](http://www.vagrantup.com/) is the one for creating virtual machines for testing easily.

But I'm using [KVM](http://www.linux-kvm.org/page/Main_Page) mainly and would like to create virtual machines for testing on a KVM based virtual machine.

[LXC](http://lxc.sourceforge.net/) suits that purpose.

For testing purpose, how to create LXC system containers easily is important. So I've created a Puppet module to create LXC system containers easily.

[mizzy/puppet-lxc-test-box](https://github.com/mizzy/puppet-lxc-test-box)

----

## How To Use

First, git clone puppet-lxc-test-box module and puppet-sysctl module.


```
$ git clone git://github.com/mizzy/puppet-lxc-test-box.git lxc-test-box
$ git clone git://github.com/duritong/puppet-sysctl.git sysctl
```

Next, write a manifest to create system containers.

```
include lxc-test-box

Exec { path => '/sbin:/usr/sbin:/bin:/usr/bin' }

lxc-test-box::lxc::setup { 'proxy': ipaddress => '172.16.0.2' }
lxc-tets-box::lxc::setup { 'www':   ipaddress => '172.16.0.3' }
lxc-test-box::lxc::setup { 'db':    ipaddress => '172.16.0.4' }
```

Apply this manifest.

```
$ sudo puppet apply --modulepath=. lxc-test-box.pp
```

3 containers will be created.
