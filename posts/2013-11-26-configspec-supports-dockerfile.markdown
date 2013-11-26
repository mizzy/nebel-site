---
title: configspec で Dockerfile を生成できるようにした
date: 2013-11-26 14:47:38 +0900
---

[configspec](http://mizzy.org/blog/2013/11/25/1/) とか Immutable Infrastructure について、[@kazuho](https://twitter.com/kazuho) さんから色々とありがたいツッコミをいただきまして、その中で

<blockquote class="twitter-tweet" lang="en"><p>個人的にはSCMあるいはLVMの管理下において、record-cmd yum -y install httpd とかすると、コマンドがSCMのコメントに残りつつ、ファイルシステムに発生した差分が変更履歴として保存されるくらいでいいんじゃないかと思う</p>&mdash; Kazuho Oku (@kazuho) <a href="https://twitter.com/kazuho/statuses/405183158674403329">November 26, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

といった tweet があり、それは Docker でやれるけど、configspec でやることではないなー、と思っていたところ、ふと

<blockquote class="twitter-tweet" lang="en"><p>configspec から Dockerfile を生成する、というアプローチもありな気がしてきた。</p>&mdash; Gosuke Miyashita (@gosukenator) <a href="https://twitter.com/gosukenator/statuses/405184497550782464">November 26, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ってなことを思いつき、時同じくして [@naoya_ito](https://twitter.com/naoya_ito) さんからも

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/gosukenator">@gosukenator</a> configspecみたいなのがDockerfileを出力すればいいと思います</p>&mdash; Naoya Ito (@naoya_ito) <a href="https://twitter.com/naoya_ito/statuses/405185262411460608">November 26, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

とリプライいただいたので、早速実装してみた。v0.0.5 では、以下の様に Dockerfile の生成ができます。

```
$ configspec-init
Select a backend type:

  1) SSH
  2) Exec (local)
  3) Dockerfile

Select number: 3

 + spec/
 + spec/001_httpd_spec.rb
 + spec/spec_helper.rb
 + Rakefile

$ rake spec
/opt/boxen/rbenv/versions/2.0.0-p247/bin/ruby -S rspec

Package "httpd"
  should be installed

Finished in 0.00229 seconds
1 example, 0 failures

$ cat Dockerfile
RUN yum -y install httpd
```

まだ RedHat 系のパッケージインストールしか対応してないので、``RUN yum -y install`` しか出力できないけど、おいおい対応していきます。

（というか、RSpec で副作用のある何かするの、[@r7kamura](https://twitter.com/r7kamura) 氏のネタに乗っかった側面が強いんだけど、本当にこの方向性でいいの？って気がしなくもない。）
