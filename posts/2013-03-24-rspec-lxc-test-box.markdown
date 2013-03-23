---
title: Testing servers provisioned by Puppet or Chef with RSpec
date: 2013-03-24 02:29:42 +0900
---

[I've made a Puppet module for creating LXC system containers](/blog/2013/03/24/1/).Next I've tried to the basis for writing test code easily.

With [rspec-lxc-test-box](https://github.com/mizzy/rspec-lxc-test-box), you can write code for testing server status like this.

```ruby
require 'container_spec_helper'

describe 'nrpe' do
  it { should be_installed }
  it { should be_enabled   }
  it { should be_running   }
end

describe 'nagios-plugins-all' do
  it { should be_installed }
end

describe '/etc/nagios/nrpe.cfg' do
  it { should be_file }
  it { should contain 'server_port=5666' }
end

describe '/etc/nrpe.d/01base.cfg' do
  it { should be_file }
end

describe 'port 5666' do
  it { should be_listening }
end
```

This code accesses to a container through SSH and execute commands to check whether files exist, packages are installed, files contain some strings, services run, some ports listen and so on.Very simple.(But code base are specific for Red Hat and its clone OS.)

You can see how I make it simply [with these codes](https://github.com/mizzy/rspec-lxc-test-box/tree/master/spec/support/matchers).

This test code works with any servers provisioned by any tools(Puppet, Chef, CFEngine, Shell Script, Hands and so on).