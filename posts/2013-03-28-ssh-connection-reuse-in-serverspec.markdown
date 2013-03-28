---
title: serverspec で同一ホストへの SSH 接続を再利用するようにしました
date: 2013-03-28 23:09:20 +0900
---

今まで [serverspec](https://github.com/mizzy/serverspec) では、テストをひとつ実行するたびに、ホストへの SSH 接続/切断を繰り返していたのですが、バージョン 0.0.13 では、同一ホストへの SSH 接続を再利用することで、テスト時間を短縮できるようにしました。

接続の管理は serverspec-init 実行時に生成される spec/spec\_helper.rb で行っているため、0.0.12 以前から利用している方は、一度 spec/spec\_helper.rb を削除して、再度 serverspec-init を実行して再作成してください。

```
$ rm spec/spec_helper.rb
$ serverspec-init
 + spec/spec_helper.rb
```
