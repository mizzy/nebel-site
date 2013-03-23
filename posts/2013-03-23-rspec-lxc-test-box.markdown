---
title: Puppet や Chef で構築したサーバを RSpec でテストする
date: 2013-03-23 22:34:15 +0900
---

Puppet マニフェストをリファクタリングするからテスト書くぞ、ってことで、 [puppet-lxc-test-box](/blog/2013/03/22/1/) に書いたように、テストするためのシステムコンテナを簡単に作る仕組みをつくったので、今度は実際にテストコードを書くためのベースをつくってみた。

[rspec-lxc-test-box](https://github.com/mizzy/rspec-lxc-test-box)

こんな感じでテストが書ける。

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

やってることはすごく単純で、システムコンテナに対して SSH でアクセスしてコマンドを叩いて、パッケージがインストールされているか、とか、ファイルが存在するか、とか、ファイルに特定の文字列が含まれてるか、とか、サービスが動いているか、とか、特定のポートで Listen してるか、とかを確認してる。（ただし、Red Hat 系 OS を対象としてるので、他の OS ではそのままでは動かない部分もある。）

具体的にどんなことをやってるかは、[この辺](https://github.com/mizzy/rspec-lxc-test-box/tree/master/spec/support/matchers) を見てもらえば、すごく単純だということがわかると思う。

実際にコンテナに SSH でアクセスしてテストするので、別に LXC じゃなくても、KVM でも VirtualBox でも VMWare でも物理マシンでも OK だし、Puppet だろうが Chef だろうが CFEngine だろうがシェルスクリプトだろうが手動での構築だろうが、どんな構築手段でも利用できる。

[Test Kitchen](https://github.com/opscode/test-kitchen) で同じようなことできるんだから、おとなしく Puppet じゃなくて Chef 使えばいいじゃん、って思われるかもしれないけど、Test Kitchen はなんか大げさすぎて肌に合わない。見通しがいい小さなツールを組み合わせるのが好きなので、[puppet-lxc-test-box](/blog/2013/03/22/1/) とかこれとか作ってる。

これと同じようなことは、実は [@hiboma](https://twitter.com/hiboma) が既に Sqale で Chef と組み合わせてやっていて、色々参考にさせてもらった。Chef Casual Talk とかがあれば、たぶんこの辺の話をしてくれるんじゃないかな。

こういったテスト駆動サーバ構築的なアプローチは、実は [デブサミ2007出張Shibuyaイベント](http://shibuya.pm.org/blosxom/techtalks/200702.html) や [YAPC::Asia 2007 Tokyo](http://tokyo2007.yapcasia.org/sessions/2007/02/assurer_a_pluggable_server_tes.html) で発表した [Assurer というツール](http://www.slideshare.net/mizzy/assurer-a-pluggable-server-testingmonitoring-framework) でやろうとしてた。

ただ Assurer は、最初から汎用的にしようと意識しすぎて、プラガブルにしたり、複数の OS にも対応できる仕組みを入れたり、といった感じで、構想がでかすぎて自分の手に負えないものになってしまって、使わなくなってしまった。（余談。ツールとしては失敗だったけど、これきっかけで [@lamanotrama](https://twitter.com/lamanotrama) とメールのやりとりがあって、その後ペパボに入社してくれたので、ある意味成功だったと言える。）

これで Puppet マニフェストをリファクタリングするためのベースとなる仕組みはできたので、次は実際にガリガリとテストコードをを書いていく予定。
