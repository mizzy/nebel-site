---
title: serverspec の並列処理
date: 2013-06-22 23:44:52 +0900
---

[hbstudy #45](http://connpass.com/event/2580/) や [Tatsuhiko Miyagawa's Podcast ep14](http://podcast.bulknews.net/post/53587224871/ep14-docker-naoya-mizzy) なんかで、serverspec の並列処理が課題、ってな話をしていて、[Net::SSH](http://net-ssh.rubyforge.org/) がイベントドリブンな処理になってるのがネックになりそうだなー、どうしようかなー、と悩んでたんですが、とりあえず試してみた方が早いだろう、ってことで [parallel_tests](https://github.com/grosser/parallel_tests) を試してみた。

6つの VM に対して 311 examples を実行した結果で比較。

parallel_tests を使わない場合。

```
$ rspec spec
.......................................................................................................................................................................................................................................................................................................................

Finished in 50.28 seconds
311 examples, 0 failures
```

parallel_tests を使った場合。

```
$ parallel_rspec spec
8 processes for 42 specs, ~ 5 specs per process
.............................................................................................................................................................................................................................................
.....
Finished in 14.69 seconds
33 examples, 0 failures
...........

Finished in 15.32 seconds
37 examples, 0 failures
..............

Finished in 16.38 seconds
38 examples, 0 failures
................

Finished in 17.99 seconds
32 examples, 0 failures
.....

Finished in 17.74 seconds
38 examples, 0 failures
...........

Finished in 18.99 seconds
41 examples, 0 failures
...

Finished in 18.97 seconds
52 examples, 0 failures
.........

Finished in 21.49 seconds
40 examples, 0 failures

311 examples, 0 failures

Took 24.075618 seconds
```

実行時間は約50秒から約24秒と、半分ほどになった。
