---
title: octorelease という gem をつくった
date: 2014-01-31 23:15:41 +0900
---
serverspec とか specinfra の [Changes](http://serverspec.org/changes.html) を手で書くのがだるくなってきたので、自動化するために [octorelease](https://github.com/mizzy/octorelease) という gem をつくりました。

rubygems.org にもあげてあるので、gem install で入ります。

Rakefile の中に

```ruby
require "bundler/gem_tasks"
require "octorelease"
```

みたいに書いて、

```
$ rake octorelease
```

すると、 こんな感じになります。

{% img /images/2014/01/rake-octorelease.png %}

何をしてるかというと、``rake release`` した後に、前のバージョンとリリースするバージョンの間に含まれるプルリクエストを``git log``で拾って、各プルリクエストに ``Released as vX.X.X.`` とコメントをつけ、GitHub 上にリリースを作成し、リリースの本文にはプルリクエストへリンクを張る、ってなことをやってます。

プルリクへのコメントはこんな感じでつきます。

{% img /images/2014/01/octorelease-comment.png %}

これは、プルリクしてくれた人に対して、リリースしたよ、ということを知らせるために、以前から手動でコメントしてたんですが、ルーチンワークなので自動でやるようしました。

リリースはこんな感じで作られます。

{% img /images/2014/01/octorelease-releases.png %}

同僚の [linyows](https://github.com/linyows) 作の [capistrano-github-releases](https://github.com/linyows/capistrano-github-releases) インスパイアです。
