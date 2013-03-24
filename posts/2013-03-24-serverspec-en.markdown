---
title: serverspec - a rubygem for testing provisioned servers with RSpec
date: 2013-03-24 18:55:10 +0900
---

In [Testing servers provisioned by Puppet or Chef with RSpec](/blog/2013/03/24/2/), I wrote how to test provisioned servers with RSpec.

I've created a rubygem [serverspec](https://rubygems.org/gems/serverspec) for that purpose.

[mizzy/serverspec](https://github.com/mizzy/serverspec)


You can install serverspec with gem install.

```
$ gem install serverspec
```

serverspec-init command creates template files and directories.


```
$ serverspec-init
 + spec/
 + spec/www.example.jp/
 + spec/www.example.jp/httpd_spec.rb
 + spec/spec_helper.rb
 + Rakefile
```


spec/www.example.jp/httpd_spec.rb contains example spec code.


```
require 'spec_helper'

describe 'httpd' do
  it { should be_installed }
  it { should be_enabled   }
  it { should be_running   }
end

describe 'port 80' do
  it { should be_listening }
end

describe '/etc/httpd/conf/httpd.conf' do
  it { should be_file }
  it { should contain "ServerName www.example.jp" }
end
```

You can write test code like this.

You may need some settings in ~/.ssh/config and ssh-agent for logging into the target server without the password/passphrase.

```
Host *.example.jp
   User root
   IdentityFile ~/.ssh/for_serverspec_rsa
```

Run tests with rake spec.

```
$ rake spec
/usr/bin/ruby -S rspec spec/www.example.jp/httpd_spec.rb
......

Finished in 0.99715 seconds
6 examples, 0 failures
```

