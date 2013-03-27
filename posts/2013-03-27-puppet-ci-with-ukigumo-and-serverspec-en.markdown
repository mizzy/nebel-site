---
title: Continuous Integration of Puppet with Ukigumo and serverspec
date: 2013-03-27 22:36:46 +0900
---

I made Puppet CI enviroment with [Ukigumo](http://ukigumo.github.com/ukigumo/) . I realize following things.

 * Manage Puppet manifests by Git repository
 * Set up [Ukigumo Server](http://ukigumo.github.com/Ukigumo-Server/) 
 * Make LXC system containers with [puppet-lxc-test-box](/blog/2013/03/24/1)
 * Run [my own Ukigumo Client script](https://gist.github.com/mizzy/5252543) periodically by cron
   * If master branch of Puppet manifests repository is updated, pull manifests, apply them to LXC system containers and post results to Ukigumo Server.
   * Run [serverspec](/blog/2013/03/24/4) tests to LXC system containers and post results to Ukigumo Server.


This is Ukigumo Server's top page. Latest results are listed up.

{% img /images/2013/03/ukigumo-top.jpg %}

This is the detail of the result of applying Puppet manifests.

{% img /images/2013/03/ukigumo-puppet.jpg %}

This is the detail of the results of serverspec tests.

{% img /images/2013/03/ukigumo-serverspec.jpg %}

Alaso results are posted to IRC through [Ikachan](http://search.cpan.org/~yappo/App-Ikachan-0.11/lib/App/Ikachan.pm).


{% img /images/2013/03/ukigumo-irc.jpg %}

I will refactor Puppet manifests upon this CI environment.
