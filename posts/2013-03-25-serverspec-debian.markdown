---
title: serverspec が Debian 対応した（してもらった）
date: 2013-03-25 01:52:46 +0900
---

[構築済みサーバを RSpec でテストする serverspec という gem をつくった](/blog/2013/03/24/3/) で、「Red Hat 系 Linux 前提のつくりになってしまっているので、他のディストリビューションや OS で利用したい、という方は、ぜひプルリクエストください」と書いていたら、早速 [Debian 系 OS 対応のプルリクエスト](https://github.com/mizzy/serverspec/pull/1) をいただきました。ありがとうございます！

単に Debian 系 OS に対応するだけではなく、他の OS にも対応できるよう拡張しやすい形に書き換えていただいたり、serverspec 自体の spec も追加していただいたりと、至れり尽くせりで感謝感謝です。

```ruby
c.include(Serverspec::DebianHelper, :os => :debian)
```

みたいな書き方も知らなかったので、大変参考になりました。

[README](https://github.com/mizzy/serverspec/blob/master/README.md) にも書いてありますが、こんな感じで OS を指定します。

```ruby
require 'spec_helper'

describe 'httpd', :os => :debian do
  it { should be_installed }
  it { should be_enabled   }
  it { should be_running   }
end

describe 'port 80', :os => :debian do
  it { should be_listening }
end

describe '/etc/httpd/conf/httpd.conf', :os => :debian do
  it { should be_file }
  it { should contain "ServerName www.example.jp" }
end
```

``:os => :debian`` と何度も書くのが面倒なら、

```ruby
require 'spec_helper'

describe 'www.example.jp', :os => :debian do
  it do
    'httpd'.should be_installed
  end
  it do
    'httpd'.should be_enabled
  end
  it do
    'httpd'.should be_running
  end

  it do
    'port 80'.should be_listening
  end

  conf = '/etc/httpd/conf/httpd.conf'
  it do
    conf.should be_file
  end
  it do
    conf.should contain "ServerName www.example.jp"
  end
end
```

とか書いてもいいですし、

``serverspec-init`` で生成される spec/spec_helper.rb に

```ruby
require 'serverspec'
require 'pathname'

RSpec.configure do |c|
  c.include(Serverspec::DebianHelper)
  c.before do
    c.host = File.basename(Pathname.new(example.metadata[:location]).dirname)
  end
end
```

な感じで ``c.include(Serverspec::DebianHelper)`` を追加して、

```ruby
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

といった感じで、spec 内では OS は指定しない、といった書き方もできます。

好きなスタイルを選んでください。