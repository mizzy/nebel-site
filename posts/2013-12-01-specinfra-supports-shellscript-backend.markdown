---
title: configspec/serverspec でシェルスクリプトを生成できるようにした
date: 2013-12-01 00:20:31 +0900
---

specinfra で [ShellScript backend に対応](https://github.com/mizzy/specinfra/pull/1) したので、configspec や serverspec で実行されるコマンドをシェルスクリプト形式でダンプできるようになった。

例えば configspec の場合

```ruby
require 'configspec'

include SpecInfra::Helper::ShellScript
include SpecInfra::Helper::RedHat
```

といった spec_helper.rb を用意して

```ruby
require 'spec_helper'

describe package('httpd') do
  it { should be_installed }
end
```

といった内容の spec を書いて実行すると

```sh
#!/bin/sh

yum -y install httpd
```

こんな内容の spec.sh というファイルを生成してくれる。

また、serverspec の場合

```ruby
require 'serverspec'

include SpecInfra::Helper::ShellScript
include SpecInfra::Helper::RedHat
```

といった spec_helper.rb を用意して

```ruby
require 'spec_helper'

describe package('httpd') do
  it { should be_installed }
end

describe service('httpd') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port(80) do
  it { should be_listening }
end

describe file('/etc/httpd/conf/httpd.conf') do
  it { should be_file }
  it { should contain "ServerName users501" }
end
```

という serverspec-init で生成されるサンプルの spec を実行すると

```sh
#!/bin/sh

rpm -q httpd
chkconfig --list httpd | grep 3:on
service httpd status
netstat -tunl | grep -- :80\
test -f /etc/httpd/conf/httpd.conf
grep -q -- ServerName\ users501 /etc/httpd/conf/httpd.conf || grep -qF -- ServerName\ users501 /etc/httpd/conf/httpd.conf
```

こんな内容の spec.sh を吐き出してくれる。

さらに ``include SpecInfra::Helper::RedHat`` を ``include SpecInfra::Helper::Solaris11`` に変えると

```sh
#!/bin/sh

pkg list -H httpd 2> /dev/null
svcs -l httpd 2> /dev/null | egrep '^enabled *true$'
svcs -l httpd status 2> /dev/null | egrep '^state *online$'
netstat -an 2> /dev/null | grep -- LISTEN | grep -- \\.80\
test -f /etc/httpd/conf/httpd.conf
grep -q -- ServerName\ users501 /etc/httpd/conf/httpd.conf || grep -qF -- ServerName\ users501 /etc/httpd/conf/httpd.conf
```

といった感じで、Solaris 11 用のシェルスクリプトを吐き出してくれる。（実際にはパッケージ名が違ってそのままでは使えないだろうけど。）

serverspec の場合は、シェルコマンドだけじゃなく Ruby で処理してる部分もあるので、ダンプされるシェルスクリプトで serverspec がやってることをそのまま再現できるわけではないし、そもそもシェルスクリプトでダンプすることに意味があるのか、という感じだけど、specinfra 側で対応するだけで、configspec と serverspec 両方で使えるようになる、という実例として挙げてみた。