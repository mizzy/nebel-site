---
title: 最小手順の Vagrant base box の作り方
date: 2013-03-11 22:28:50 +0900
---

[Vagrant](http://www.vagrantup.com/) の base box をつくるためのツールとして [VeeWee](https://github.com/jedi4ever/veewee) があって、これはこれで素晴らしいツールなんだけど、VeeWee は裏で ISO イメージをダウンロードしたり、インストーラを走らせたりで、時間もかかるし大げさな感じがするので、もっと簡略化できないか、ってことでやってみた。

[最小手順のVMイメージの作り方](blog/2013/02/24/1/) で紹介したシェルスクリプトで作成した VM イメージに対して、以下のようにコマンドを実行するだけで、package.box ができあがる。

```text
# VBoxManage convertfromraw --format vmdk /tmp/sl63.img /tmp/sl63.vmdk
# VBoxManage createvm --name SL6.3-x86_64 --register
# VBoxManage modifyvm SL6.3-x86_64 --memory 512 --acpi on --nic1 nat
# VBoxManage storagectl SL6.3-x86_64 --name "IDE Controller" --add ide
# VBoxManage modifyvm SL6.3-x86_64 --hda /tmp/sl63.vmdk
# vagrant package --base SL6.3-x86_64
```

できあがった package.box に対して以下のようにすれば、VM が起動する。

```text
$ vagrant box add sl63-x86_64 package.box
$ vagrant init sl63-x86_64
$ vagrant up
```

ただし、[Vagrant Documentation - Documentation - Base Boxes](http://docs-v1.vagrantup.com/v1/docs/base_boxes.html) にあるような、vagrant ユーザの作成とか、鍵の設定なんかはしてないため、``vagrant ssh`` ではログインできないので、``ssh root@localhost -p 2222 `` で、パスワードは root でログインする。

この辺の設定もシェルスクリプトに組み込んじゃえばいいんだろうけど、まずは base box を簡単に作れるかどうかだけ確かめたかったので、今日はここまで。


