---
title: Rust で D-Bus 経由で systemd から情報を得る
date: 2017-10-11 12:29:40 +0900
---

色々試行錯誤したのでメモ。

----

## 結論

[dbus crate](https://crates.io/crates/dbus) を使う。

----

## 経緯

開発中の [libspecinfra](http://atl.recruit-tech.co.jp/blog/4339/) で、systemd 配下の service の状態を取得できるようにするための provider を書こうと思い、色々調べたりコード書いて試したりした。

----

## 使えそうな crates を探す

まずは目的に合う crates がないか [crates.io](https://crates.io/) で検索。ざっと以下のようなものが見つかる。

* [systemd](https://crates.io/crates/systemd)
* [systemd-dbus](https://crates.io/crates/systemd-dbus)
* [dbus](https://crates.io/crates/dbus)
* [dbus-bytestream](https://crates.io/crates/dbus-bytestream)

systemd crate は [libsystemd](https://github.com/systemd/systemd/tree/master/src/libsystemd) の Rust インターフェースで、[sd-daemon](https://www.freedesktop.org/software/systemd/man/sd-daemon.html)、[sd-id128](https://www.freedesktop.org/software/systemd/man/sd-id128.html)、[sd-journal](https://www.freedesktop.org/software/systemd/man/sd-journal.html)、[sd-login ](https://www.freedesktop.org/software/systemd/man/sd-login.html) に対応している。が [sd-bus](https://www.freedesktop.org/software/systemd/man/sd-bus.html) は [まだ実装が不完全](https://github.com/jmesmon/rust-systemd/blob/aead34dcf64e90014da0fadfe54ea439a19ce8c4/src/lib.rs#L68) なようなので、目的には合わなさそう、と判断。

systemd-dbus crate は2年半以上更新がなく、rust 1.19.0 でコンパイルが通らなかったので断念。

他に systemd を直接扱える、目的に適いそうな crate が見当たらなかったので、D-Bus が扱える crate ってことで、dbus crate と dbus-bytestream create を試してみることにした。

----

## dbus-send で D-Bus を理解する

dbus crate にしても dbus-bytestream crate にしても、ざっとドキュメントやコードを読んだ感じ、D-Bus でどういった形でメッセージのやりとりがなされているのかを理解しないと、使うのは無理だなこれは、と思ったので、まずは [dbus-send](https://dbus.freedesktop.org/doc/dbus-send.1.html) コマンドで必要な情報が得られるかどうかトライしてみた。

libspecinfra でやりたいことのひとつは、サービスが動いているかどうかを調べること。dbus-send では以下のような形で実行すれば、この情報が得られることがわかった。

まずはユニット名(ssh.service)からオブジェクトパス(/org/freedesktop/systemd1/unit/ssh_2eservice)を取得。

```
$ dbus-send --system \
   --dest=org.freedesktop.systemd1 \
   --type=method_call \
   --print-reply \
   /org/freedesktop/systemd1 \
   org.freedesktop.systemd1.Manager.GetUnit \
   string:ssh.service

method return time=1507693363.257785 sender=:1.10 -> destination=:1.220 serial=3078 reply_serial=2
   object path "/org/freedesktop/systemd1/unit/ssh_2eservice"
```

`--dest=org.freedesktop.systemd1` で接続先のバス名を指定。`/org/freedesktop/systemd1` が操作対象のオブジェクトパス、`org.freedesktop.systemd1.Manager` がインターフェースで、それに続く `GetUnit` が呼び出すメソッド、`string:ssh.service` がメソッドに渡す引数、という形式になっている。


このオブジェクトパスの ActiveState プロパティを取得。

```
$ dbus-send --system \
   --dest=org.freedesktop.systemd1 \
   --type=method_call \
   --print-reply \
   /org/freedesktop/systemd1/unit/ssh_2eservice \
   org.freedesktop.DBus.Properties.Get \
   string:org.freedesktop.systemd1.Unit \
   string:ActiveState

method return time=1507693392.955268 sender=:1.10 -> destination=:1.221 serial=3079 reply_serial=2
   variant       string "active"
```

これでサービスの状態を得ることができた。

どのようなメソッドやプロパティがあるかは [The D-Bus API of systemd/PID 1](https://www.freedesktop.org/wiki/Software/systemd/dbus/) に載っている。

----

## Rust で dbus-send で得たのと同じ情報を得る

dbus crate を使って以下のようなコードを書けば良い。

{% gist 0210a1b8c56c1bf1411b1b8e310e90d8 %}

試したコードは Cargo.toml 等も含めて [GitHub](https://github.com/mizzy/rust-systemd-playground) に置いてある。

dbus crate は [サンプルコード](https://github.com/diwic/dbus-rs/tree/master/dbus/examples) もあるし、[ドキュメント](https://github.com/diwic/dbus-rs/blob/master/dbus/examples/argument_guide.md) もあるので、ドキュメントがほとんどない dbus-bytestream crate と比べると、比較的扱いやすいように思える（といっても、ドキュメント読めばすべてわかる、というわけではなく、コードも読んで色々試行錯誤したけど）。

dbus-bytestream も同時に試したけど、取得した ActiveState の情報をデコードする方法がよくわからないまま、dbus crate の方が動いたので、途中で断念した。なので、GitHub 上にある dbus-bytestream を使ったコードはエラーで動かない。

