---
title: Dockerコンテナに入るなら SSH より nsinit が良さそう
date: 2014-06-22 19:21:44 +0900
---

## 追記

[はてブでつっこみもらいました](http://b.hatena.ne.jp/entry/mizzy.org/blog/2014/06/22/1/) が、実行するカレントディレクトリは /var/lib/docker/execdriver/native/$id を使うのが正しいようです。（情報読み違えてた。）こちらには `container.json` があるので、ソースツリーからコピーしてくる必要ないですね。

また、コンテナ ID 取得は、`docker ps -q --no-trunc` の方が良い、とも教えていただきました。

つっこみにしたがって、最後の方の説明とシェル関数書き換えました。

つっこみありがとうございます！

---

## tl; dr

タイトルまま

---

## 経緯

Docker でつくったコンテナの中に入って状態を確認するために、コンテナ内で sshd を立ち上げてアクセスする、ってなことを以前やってたんですが、コンテナ内で sshd を立ち上げる、というやり方がいまいちだし、そもそもコンテナの仕組みから考えれば、別に sshd を立ち上げなくても、コンテナと同じ namespace と rootfs に bash なりのプロセスを閉じ込めてやれば良いわけで、そういったことは既に考えている人はいるだろうし、ツールとかありそうだな、ってことで、

<blockquote class="twitter-tweet" lang="en"><p>Dockerで中を見たいコンテナのPID namespaceとchrootをカレントシェルに割り当てることが簡単にできるようなツールがあれば、中でsshとか立てなくていいかな。</p>&mdash; Gosuke Miyashita (@gosukenator) <a href="https://twitter.com/gosukenator/statuses/479289206108217344">June 18, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

とつぶやいてみたら、

<blockquote class="twitter-tweet" data-conversation="none" lang="en"><p><a href="https://twitter.com/gosukenator">@gosukenator</a> nsenter -- chroot /bin/bash とかでいけないですかねー</p>&mdash; TenForward (@ten_forward) <a href="https://twitter.com/ten_forward/statuses/479297375115042817">June 18, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

と、nsenter なるものの存在を教えて頂いた。

<blockquote class="twitter-tweet" data-conversation="none" lang="en"><p><a href="https://twitter.com/gosukenator">@gosukenator</a> nsenter はちょっと新しい util-linux にしかないので、ソースからコンパイルする必要あると思います。&#10;RHEL/CentOS7 は知らないですけど、Ubuntu 14.04 にはありませんでした。</p>&mdash; TenForward (@ten_forward) <a href="https://twitter.com/ten_forward/statuses/479297956969869312">June 18, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

で、これを見るとちょっと面倒かな、と思ったけど、

<blockquote class="twitter-tweet" data-conversation="none" lang="en"><p><a href="https://twitter.com/gosukenator">@gosukenator</a> docker 的にはそのページに書かれている nsinit を使うのが正解かもしれませんね。docker のソースツリーに入ってるツールですし :-)&#10;(nsinit すっかり忘れてた)</p>&mdash; TenForward (@ten_forward) <a href="https://twitter.com/ten_forward/statuses/479304239584251904">June 18, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

この nsinit は golang 製なので、golang が動く環境であれば go get で入れることができて楽そうなので、nsinit を試してみることにした。

---

## nsinit の使い方

golang 環境は既に整っていて、GOPATH が設定されていて、PATH に $GOPATH/bin が含まれている、という前提。

`go get` で `nsinit` を入れる。

```
$ go get github.com/docker/libcontainer/nsinit
```

こんな感じで実行。

```
$ sudo -s
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
917756ba04a2        ubuntu:14.04        /bin/bash           51 minutes ago      Up 51 minutes                           lonely_tesla
# cd /var/lib/docker/execdriver/native/9177*
# nsinit exec /bin/bash
daemon@koye:/$
```

cd して nsinit、ってやるのは、一般ユーザからだとパーミッションの関係でタブ補完が効かなくてだるいので、シェル関数書いてみた。

```
docker-attach()
{
  id=`sudo docker ps -q --no-trunc $1`
  root=/var/lib/docker/execdriver/native/$id
  sudo sh -c "cd $root && $GOPATH/bin/nsinit exec $2"
}
```

この関数つかって、コンテナIDと実行するプログラムを与えれば、一発でコンテナの中に入れて便利。

```
vagrant@vagrant:~$ docker-attach 9177 /bin/bash
daemon@koye:/$
daemon@koye:/$ ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
daemon       1     0  0 10:38 ?        00:00:00 /bin/bash
daemon      14     1  0 10:44 ?        00:00:00 ps -ef
```
