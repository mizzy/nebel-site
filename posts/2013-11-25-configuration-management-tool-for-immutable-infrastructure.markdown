---
title: configspec という Immutable Infrastructure 用 Configuration Management Tool をつくってみた
date: 2013-11-25 23:28:50 +0900
---

[Immutable Infrastructure の有用性 - Togetter](http://togetter.com/li/594684) の流れの勢いで、[インフラ系技術の流れ](http://mizzy.org/blog/2013/10/29/1/) とか [Rebuild: 25: Immutable Infrastructure (Naoya Ito, Gosuke Miyashita)](http://rebuild.fm/25/) とかで言ってたような、冪等性とか依存関係とかを考慮しないシンプルな Configuratin Management Tool である [configspec](https://github.com/mizzy/configspec) をつくってみました。[rubygems.org](https://rubygems.org/gems/configspec) にもアップしてます。

この手のツールに自分が望む要件は以下の様な感じ。

* 冪等性とかどうでもいい
  * まっさらな状態からのセットアップでしか使わない
* 依存関係とかどうでもいい
  * ファイル名順、上から書いた順で実行してく 
* 対象サーバに余分なものをインストールしたくない
  * 対象サーバに SSH さえできれば OK
* シェルスクリプトよりは抽象度を高めたい
  * 今さらシェルスクリプトでのセットアップには戻りたくない…

使い方はこんな感じ。

```
$ configspec-init
Select a backend type:

  1) SSH
  2) Exec (local)

Select number: 1

Vagrant instance y/n: y
Auto-configure Vagrant from Vagrantfile? y/n: n
Input vagrant instance name: www
 + spec/
 + spec/www/
 + spec/www/001_httpd_spec.rb
 + spec/spec_helper.rb
 + Rakefile

 ~/tmp/configspec/spec
$ rake spec
/opt/boxen/rbenv/versions/2.0.0-p247/bin/ruby -S rspec spec/www/001_httpd_spec.rb

Package "httpd"
  should be installed

Finished in 3.44 seconds
1 example, 0 failures
```

サンプルとして生成される ``001_httpd_spec.rb`` の中身はこんな感じ。

```ruby
require 'spec_helper'

describe package('httpd') do
  it { should be_installed }
end
```

これによって、``rake spec`` を実行すると、裏では ``yum -y install httpd`` が実行される。

これを見て、serverspec とほぼ同じだ、と思った方、正解です。コードも serverspec からとほんどコピペしてます。違いは、``be_installed`` で実行されるのが、serverspec の場合は ``rpm -q`` で、configspec では ``yum install -y`` といったところぐらいですね。

この configspec は、とりあえず proof of concept として作ってみただけで、RedHat 系 OS でパッケージインストールしかできないので、まだまだ実用には耐えませんが、つくりが serverspec とまんま一緒なので、同じような感じで拡張していけます。

serverspec にこういった機能を組み込むことも考えましたが、serverspec のようにサーバの状態をテストするのと、configspec のようにサーバに副作用のある何かを実行するのでは、書くべき内容が異なってくるだろう、と考えて、別プロダクトにしました。

RSpec の副産物として副作用のある何かが実行されるというのは、もちろん [Sitespec](http://r7kamura.github.io/2013/11/18/sitespec.html) の影響受けてます。
