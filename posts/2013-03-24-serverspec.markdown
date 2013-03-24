---
title: 構築済みサーバを RSpec でテストする serverspec という gem をつくった
date: 2013-03-24 17:35:20 +0900
---

[Puppet や Chef で構築したサーバを RSpec でテストする](/blog/2013/03/23/1/) で書いた仕組みを使いやすくするために [serverspec](https://github.com/mizzy/serverspec) という名前で gem 化してみた。

rubygems.org にも登録してあるので、gem install でインストールできる。

```
$ gem install serverspec
```

インストールしたら、適当なディレクトリで serverspec-init を実行。すると、雛形となるディレクトリやファイルを生成する。

```
$ serverspec-init
 + spec/
 + spec/www.example.jp/
 + spec/www.example.jp/httpd_spec.rb
 + spec/spec_helper.rb
 + Rakefile
```

spec/www.example.jp/httpd_spec.rb がサンプルテストコードで、こんな感じになってる。

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

これに倣って spec/target.example.jp/xxxxx_spec.rb というファイルをつくって、テストを書いていく。

テスト対象のホストには SSH でアクセスするので、パスワード入力しなくて良いように、~/.ssh/config を書いたり、ssh-agent を利用したりすると良いでしょう。

```
Host *.example.jp
   User root
   IdentityFile ~/.ssh/for_serverspec_rsa
```

rake spec でテストを実行。

```
$ rake spec
/usr/bin/ruby -S rspec spec/www.example.jp/httpd_spec.rb
......

Finished in 0.99715 seconds
6 examples, 0 failures
```

Red Hat 系 Linux 前提のつくりになってしまっているので、他のディストリビューションや OS で利用したい、という方は、ぜひプルリクエストください。