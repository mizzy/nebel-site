---
title: configspec の Dockerfile バックエンドで FROM をサポートした
date: 2013-12-01 00:08:16 +0900
---

[configspec で Dockerfile を生成できるようにした](http://mizzy.org/blog/2013/11/26/1/) のだけど、Dockerfile 生成するなら、``FROM`` の定義は外せないだろう、ってことで、[できるようにした](https://github.com/mizzy/configspec/pull/4) 。

```ruby
require "configspec"

include Configspec::Helper::Dockerfile
include SpecInfra::Helper::RedHat
```

こんな spec_helper.rb を用意して、

```ruby
require 'spec_helper'

describe dockerfile do
  it { should be_from 'centos' }
end

describe package('httpd') do
  it { should be_installed }
end
```

ってな spec を書いて実行したら、

```
FROM centos
RUN yum -y install httpd
```

という内容の Dockerfile を生成してくれる。

Dockerfile バックエンドは specinfra の方で実装しても良かったんだけど、serverspec では使い道ないな、と思ったので、configspec の方で実装した。
