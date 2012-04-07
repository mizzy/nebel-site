---
layout: post
title: ChefFirstImpression
date: 2009-05-05 14:45:58 +0900
---


Puppet 作者 [Luke Kanies 氏のブログエントリ](http://madstop.com/2009/01/16/opscode-announces-chef-a-puppet-competitor/) にて、Puppet の競合となる [Chef](http://wiki.opscode.com/display/chef/Home) というソフトウェアについて触れられていた。

ソフトウェアのポジション的にも、使われている用語的にも、かなり Puppet を意識している模様。開発言語が Ruby という点も Puppet と同じ。

Luke 氏としては、Puppet を散々使っていながらあまりコードに貢献することなしに、新しいプロジェクトを立ち上げるってどうなのよ、とか、競合が存在するのはいいことなんだけど、 そんなたくさん競合がある分野じゃないんだから、もっと色々話してくれてもいいのに、といった不満があるみたい。

また、名前が SEO 的にまずいよね、自分もそれで苦労した、といったことや、Puppet が外部 DSL なのに対し、Chef は内部 DSL なんだけどそれってどうなのよ、的なことも書いてますね。自分も外部 DSL の方が、制限があるけどわかりやすくていいんじゃないかとは思ってます。

で、"I’m not afraid of competition." と言っていて、Puppet の競合なんて笑わせるぜ、的なことを言ってる（実際にこういうニュアンスかはよくわからないけど）わけですが、やはり気にはなるので試してみました。

最初は CentOS 5.2 で環境作ろうとしてたんですが、あまりにも面倒で挫折したので、[インストールガイド](http://wiki.opscode.com/display/chef/Installation) で対象としてる Ubuntu で試してみました。

# インストール手順

今回はひとつの Ubuntu 8.10 VM 上で、サーバ/クライアント両方を兼ねる形でセットアップしました。基本的には [インストールガイド](http://wiki.opscode.com/display/chef/Installation) にある通りなんですが、いくつか説明通りではうまくいかなかった点があるので、その点をここで補足しておきます。

「Install Ruby and Rubygems」では、libhttp-access2-ruby も合わせてインストールしておく必要があります。

	
	$ sudo apt-get install ruby ruby1.8-dev rubygems build-essential libhttp-access2-ruby
	

また、「Bring up the Chef Server」にある、

	
	$ sudo chef-solo -r http://wiki.opscode.com/download/attachments/1179839/chef-server-install-solo.tar.gz
	

ですが、これをそのまま実行しても、エラーが出て途中で止まってしまいました。この手順では、chef-solo というスタンドアローンな chef クライアントを使って、chef に必要となるパッケージをインストールし、初期化等を行っているのですが、runit パッケージと couchdb パッケージのインストール部分でこけてました。なので、まずは一度上記コマンドを実行してエラーが出た後に、この2つのパッケージを手動でインストールしておきます。

	
	$ sudo apt-get install runit couchdb
	

それから、http://wiki.opscode.com/download/attachments/1179839/chef-server-install-solo.tar.gz の展開先にある二つのファイルを修正し、runit と couchdb をインストールしている部分をコメントアウトします。

/tmp/chef-solo/cookbooks/runit/recipes/default.rb

	
	#  package "runit" do
	#    action :install
	#    notifies :run, resources(:execute => "start-runsvdir")
	#  end
	

/tmp/chef-solo/cookbooks/chef/recipes/server.rb

	
	#package "couchdb"
	

修正後、ファイルを tar.gz で固めます。

	
	$ cd /tmp
	$ tar cvf chef-solo.tar chef-solo
	$ gzip chef-solo.tar
	

その後この tar.gz ファイルを指定して、chef-solo を走らせます。

	
	$ sudo chef-solo -r /tmp/chef-solo.tar.gz
	

これでインストールは完了し、ウェブブラウザで 4000 番ポートにアクセスすることができるようになります。


# Chef Repository の作成

インストールの次に行うのは、[Chef Repository の作成](http://wiki.opscode.com/display/chef/Chef+Repository) です。Chef Repository とは、Chef でサーバ管理をするために必要な Cookbooks(Puppet でいうマニフェス）や設定ファイル等を管理するためのリポジトリです。

ここも基本的には [Wiki の手順書](http://wiki.opscode.com/display/chef/Chef+Repository) の通りなので、その通りに実行すればいいだけなんですが、いくつか補足を。

リポジトリの雛形を作成するところは、git clone してますので、当然 git が必要となります。なので、あらかじめインストールしておきます。

	
	$ sudo apt-get install git git-core
	

rake new_cookbook してる手順ですが、これは cookbook の雛形となるファイルを生成してくれます。

	
	$ rake new_cookbook COOKBOOK=apache
	(in /home/mizzy/chef-repo)
** Creating cookbook apache
	

を実行すると、以下のようなディレクトリ/ファイルが生成されます。

	
	$ ls -FR cookbooks/apache/
	cookbooks/apache/:
	attributes/  definitions/  files/  libraries/  recipes/  templates/
	
	cookbooks/apache/attributes:
	
	cookbooks/apache/definitions:
	
	cookbooks/apache/files:
	default/
	
	cookbooks/apache/files/default:
	
	cookbooks/apache/libraries:
	
	cookbooks/apache/recipes:
	default.rb
	
	cookbooks/apache/templates:
	default/
	
	cookbooks/apache/templates/default: 
	


例えば、cookbooks/apache/recipes/default.rb の内容は以下のようになってます。

	
	#
	# Cookbook Name:: apache
	# Recipe:: default
	#
	# Copyright 2009, Example Com
	#
	# Licensed under the Apache License, Version 2.0 (the "License");
	# you may not use this file except in compliance with the License.
	# You may obtain a copy of the License at
	#
	#     http://www.apache.org/licenses/LICENSE-2.0
	#
	# Unless required by applicable law or agreed to in writing, software
	# distributed under the License is distributed on an "AS IS" BASIS,
	# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	# See the License for the specific language governing permissions and
	# limitations under the License.
	#
	


rake install を実行すると、作成/編集した cookbooks を /var/chef/cookbooks の下に配置してくれたり、cofig/server.rb, client.rb, solo.rb を /etc/chef の下に配置してくれたりします。なので、雛形を git clone したままだと、勝手に設定が書き換えられるので注意が必要です。

実行時には、rake update (upstream リポジトリからの pull) と rake test も合わせて実行してくれ、sudo も自動的に実行してくれます。実行した結果は以下のようになります。

	
	$ rake install
	(in /home/mizzy/chef-repo)
** Updating your repository
	Already up-to-date.
** Testing your cookbooks for syntax errors
	Testing recipe /home/mizzy/chef-repo/cookbooks/apache/recipes/default.rb: Syntax OK
** Installing your cookbooks
* Creating Directories
* Installing new Cookbooks
	sending incremental file list
	README
	          54 100%    0.00kB/s    0:00:00 (xfer#1, to-check=10/12)
	apache/
	apache/attributes/
	apache/definitions/
	apache/files/
	apache/files/default/
	apache/libraries/
	apache/recipes/
	apache/recipes/default.rb
	         628 100%   18.04kB/s    0:00:00 (xfer#2, to-check=1/12)
	apache/templates/
	apache/templates/default/
	
	sent 1063 bytes  received 86 bytes  2298.00 bytes/sec
	total size is 682  speedup is 0.59
* Installing new Site Cookbooks
	sending incremental file list
	README
	          96 100%    0.00kB/s    0:00:00 (xfer#1, to-check=0/2)
	
	sent 178 bytes  received 31 bytes  418.00 bytes/sec
	total size is 96  speedup is 0.46
* Installing new Chef Server Config
* Installing new Chef Client Config 
	


# Chef クライアント のサーバへの登録

Chef クライアントを動作させるためには、まずは Chef サーバへのノード登録が必要となります。手順は http://wiki.opscode.com/display/chef/Nodes#Nodes-RegistrationviatheWebUI の通りで、サーバの 4000 番ポートにブラウザでアクセスし、

1. 右上の「Login」をクリックして、OpenID でログインする
1. 上部の「Registration」をクリックする
1. 対象となるノードの「Validation」をクリックする

で完了です。

ここで気になるのは、OpenID でログインするので、有効な OpenID アカウントさえ持っていれば、とりあえずログインできちゃうんですよね。なので、デフォルトで誰でもログインできちゃうような状態なんで、これはまずいだろ、と。

それから、[Nodes have OpenIDs](http://wiki.opscode.com/display/chef/Nodes#Nodes-NodeshaveOpenIDs) のところを読むと、内部的に Chef サーバがノードを認証するための仕組みとしても OpenID を使っているみたいなんだけど、そのメリットとか意図がさっぱりわからない。


# cookbook を 作成して Chef クライアントに適用する

サンプル cookbook の作成の仕方は、[Quick Start](http://wiki.opscode.com/display/chef/Quick+Start) を参照すれば OK です。ここでは特に補足しません。

わかりにくいのが、作成した cookbook を特定のノードに適用する方法。Puppet だと以下のようなやつ。

	
	node 'client.example.org' {
	    include apache
	}
	

これには [ウェブ UI を利用する方法](http://wiki.opscode.com/display/chef/Nodes#Nodes-ManagingNodesviatheWebUI) と [chef-client コマンドを利用する方法](http://wiki.opscode.com/display/chef/Nodes#Nodes-ManagingNodesthroughJSONatthecommandline) があります。

ウェブ UI の方では、上部メニューの「Nodes」をクリックし、該当するノードを選択。するとノードに関する詳細情報が表示されるので、適当なところをクリック。すると、テキストエリアに以下のように JSON 形式で内容が表示されて編集可能に。

	
	{
	  "name": "ubuntu",
	  "_rev": "4279229607",
	  "attributes": {
	    "kernel": {
	      "machine": "i686",
	      "name": "Linux",
	      "os": "GNU\/Linux",
	      "version": "#1 SMP Thu Nov 20 21:57:00 UTC 2008",
	      "release": "2.6.27-9-generic"
	    },
	
	    ... 中略 ...
	
	    "uptime": "4 hours 56 minutes 03 seconds",
	    "platform": "ubuntu",
	    "block_device": {
	      "ram13": {
	        "size": "131072",
	        "removable": "0"
	      },
	
	      ... 中略 ...
	
	      "ram9": {
	        "size": "131072",
	        "removable": "0"
	      }
	    },
	    "uptime_seconds": 17763
	  },
	  "json_class": "Chef::Node",
	  "recipes": [
	
	  ],
	  "chef_type": "node"
	}
	

この下のほうにある「recipes」ところに、適用したい cookbook を追加して、save すれば OK らしいのですが、うちの環境ではうまく save ができませんでした。

chef-client コマンドを使う方法では、

	
	$ sudo chef-client -j node.json
	

といった形で、JSON ファイルをロードできるようなのですが、この方法でもうまくいかず、結局試すことができませんでした。また後ほど環境作り直して再チャレンジの予定。

# まとめ

ここまでざっと使ってみた感想をまとめてみます。

* セットアップがめんどくさい。Puppet は Ruby と Facter があれば OK なのに対し、Chef はいろいろなものが必要。特に CouchDB は、CentOS 5 用のパッケージがなく、パッケージ作るのも大変そうだったので、今回は諦めた。（誰かパッケージの在り処を知っていったら教えてください。）
* OpenID をつかってる意味がよくわからない。誰か教えて。
* ウェブ UI は必要ない。すべてコマンドラインで完結してくれるほうがうれしい。
* Chef Repository の考え方ははよさげ。
   * Rakefile を覗いてみると、git と subversion に対応してるみたい。
   * rake コマンド で特定のタスクを実行できるのもいい。
   * git に対応してるのは、外部の人たちと cookbooks を共有するのに良さげ。ただ、システム管理者に git 使わせるのは厳しいかも。
* 内部 DSL よりも外部 DSL の方が、制限がある分逆に誰が書いても同じような記述になるし、分かりやすいと思うので、特にメンテナンスや他メンバーとの共有を考えると、外部 DSL である Puppet の方が個人的には好き。

今のところ、まだ Puppet からの乗換えを検討しようとは思わないけど、今後ウォッチしていこうと思います。
