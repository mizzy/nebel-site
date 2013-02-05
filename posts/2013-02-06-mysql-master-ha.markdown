---
title: MHA for MySQL の概要
date: 2013-02-06 01:50:17 +0900
---

MHA for MySQL の導入を検討していて、まずは社内の技術者向けに、MHA for MySQL の概要を伝えようと、主に [オフィシャルなドキュメント](http://code.google.com/p/mysql-master-ha/wiki/TableOfContents?tm=6) からポイントを抜粋して社内向けの Wiki に書いてみた。本当なら、オフィシャルドキュメント全体に目を通してもらうのがいいんだけど、英語なので、はじめの一歩としては敷居が高く感じる人もいるだろう、ということで。

特に外に出してまずい情報があるわけでもないので、このブログでも曝しておきます。

----

## MHA の概要

MySQL エキスパートとして世界的にも著名な松信嘉範氏による、MySQL マスターの HA 化を行うためのツール。Perl 製。

最小限のダウンタイムで、データの不整合を防ぎつつ、マスターのフェイルオーバーを行う、というのが主な機能。

また、既に動作している MySQL に影響を与えることなく導入できる。

機能は大きくわけると以下の4つ。

 * 自動的なマスターの監視とフェイルオーバー
   * トータルダウンタイム10〜30秒ぐらいで切り替え可能
 * 手動によるマスターフェイルオーバー
 * 自動的なマスターのフェイルオーバー（監視はしない）
   * 監視を既存ソフトウェア（Pacemaker など）で行う場合に有用
 * オンラインでマスターを別ホストに切り替え
   * マスターは動作してるが、ハードウェア的に怪しい兆候が見られるので、別ホストに事前に切り替えたい、などといった場合に有用
   * 0.5〜2秒ほど書き込みブロックされるだけで切り替え可能

----

## MHA のコンポーネントと動作概要

マスターの監視とフェイルオーバーを MHA で自動的に行う場合の構成は以下のようになる。

{% img /images/2013/02/components_of_mha.png Components of MHA %}

動作の流れは以下の通り。

 * Manager が MySQL Master を監視
 * ダウンを検知すると、以下を実行
   * Master の最新のバイナリログを各 Slave に保存（可能であれば）
   * 新マスターのリカバリ
     * スレーブのうちのひとつを新マスターにする
       * デフォルトでは一番新しいポジションまで進んでいるスレーブが選ばれる。設定で、このスレーブを次のマスターにする、といったこともできる。
     * 新マスターにバイナリログの最新のポジションまでのデータを反映させる
   * その他のスレーブのリカバリ 
     * バイナリログの最新のポジションまでのデータを反映させる
     * 新マスターからレプリケーションを開始

動作の詳細についてはオフィシャルドキュメントの [Sequences of MHA](http://code.google.com/p/mysql-master-ha/wiki/Sequences_of_MHA) を参照。

----

## Manager の拡張

Manager の本体である masterha_manager には拡張ポイントがいくつかあり、設定ファイル中で以下のパラメータに対してスクリプトを指定することで、動作を拡張することができる。拡張ポイントは以下の通り。

 * secondary\_check\_script
 * master\_ip\_failover_script
 * shutdown\_script
 * report_script
 * init\_conf\_load\_script
 * master\_ip\_online\_change\_script

例えば、MHA 自体には、マスターがフェイルオーバーした時に VIP を付け替える機能はないが、以下のように VIP 付け替え用のスクリプトを設定ファイルで指定すると、フェイルオーバー時に VIP の付け替えをしてくれる。（スクリプトは自分で用意する。）

```
master_ip_failover_script=/usr/local/sample/bin/master_ip_failover
```

詳細は [Custom Extensions](http://code.google.com/p/mysql-master-ha/wiki/Architecture#Custom_Extensions) を参照。

----

## Manager の設定例

拡張スクリプトの設定など、必須ではないものも含む。

```
[server default]
# mysql user and password
user=root
password=mysqlpass
# working directory on the manager
manager_workdir=/var/log/masterha/app1
# manager log file
manager_log=/var/log/masterha/app1/app1.log
# working directory on MySQL servers
remote_workdir=/var/log/masterha/app1
secondary_check_script= masterha_secondary_check -s remote_host1 -s remote_host2
ping_interval=3
master_ip_failover_script=/script/masterha/master_ip_failover
shutdown_script=/script/masterha/power_manager
report_script=/script/masterha/send_master_failover_mail
  
[server1]
hostname=host1
candidate_master=1 # 次のマスター候補

[server2]
hostname=host2

[server3]
hostname=host3
no_master=1 # このホストはマスターにしない
```

以下のように設定ファイルを指定して起動する。

```text
# masterha_manager --conf=/etc/mha.cnf
```

設定パラメータ一覧はオフィシャルドキュメントの [Parameters](http://code.google.com/p/mysql-master-ha/wiki/Parameters) を参照。

----

## チュートリアル

オフィシャルドキュメントの [Tutorial](http://code.google.com/p/mysql-master-ha/wiki/Tutorial) を参照。


----
## FAQ

[FAQ](http://code.google.com/p/mysql-master-ha/wiki/FAQ) からいくつかピックアップ。超意訳。

 * サポートされている MySQL のバージョンは？
   * 5.0 以降がサポートされている。4.1 以下はサポート対象外。
 * 特定のスレーブホストをマスターに昇格したり、逆に特定のホストはマスターに昇格しない、といったことは可能か？
   * [cadidate\_master](http://code.google.com/p/mysql-master-ha/wiki/Parameters#candidate_master) や [no\_master](http://code.google.com/p/mysql-master-ha/wiki/Parameters#no_master) といったパラメータで設定可能。
 * インタラクティブ/手動でのフェイルオーバーは可能？
   * [masterha_master_switch](http://code.google.com/p/mysql-master-ha/wiki/masterha_master_switch) 使えばOK。
 * MHA Manager 自体の冗長化は？
   * Pacemaker とか使っとけ。


----
## よくあるエラーと対処方法

オフィシャルドキュメントの [TypicalErrors](http://code.google.com/p/mysql-master-ha/wiki/TypicalErrors) を参照。
 
----
## 必要条件

オフィシャルドキュメントの [Requirements](http://code.google.com/p/mysql-master-ha/wiki/Requirements) からいくつかピックアップして超意訳。

MHA を動作させるためには、以下の設定が必要。[masterha_manager](http://code.google.com/p/mysql-master-ha/wiki/masterha_manager) や [masterha_check_repl](http://code.google.com/p/mysql-master-ha/wiki/masterha_check_repl) 実行時に自動的にチェックしてくれる。

 * root で各ノード間での SSH 公開鍵認証ができること
   * masterha\_check\_ssh コマンドでチェックできる
 * MySQL 5.0 以降のみサポート
 * マスター昇格候補のサーバで log-bin が enable になってること 
 * マスター昇格候補サーバにレプリケーション用ユーザが存在すること
 * ステートメントベースのレプリケーションでは LOAD DATA INFILE を使用してはいけない

----
## その他

 * Semi-Synchronous Replication と組み合わせることで、マスターのハードウェア故障等によるデータロスのリスクを抑えることができる
   * オフィシャルドキュメントの [Using together with Semi-Synchronous Replication](http://code.google.com/p/mysql-master-ha/wiki/UseCases#Using_together_with_Semi-Synchronous_Replication) を参照
   * Semi-Synchronous Replication については [漢(オトコ)のコンピュータ道: 最強のMySQL HA化手法 - Semi-Synchronous Replication](http://nippondanji.blogspot.jp/2009/03/mysql-ha-semi-synchronous-replication.html) が詳しい


----
## 参考 URL

 * [MHA for MySQL と DeNA のオープンソースの話](http://www.slideshare.net/matsunobu/mha-for-mysqldena)
 * [ mysql-master-ha - MHA for MySQL: Master High Availability Manager and tools for MySQL - Google Project Hosting](http://code.google.com/p/mysql-master-ha/)
 * [yoshinorim/mha4mysql-node on GitHub](https://github.com/yoshinorim/mha4mysql-node)
 * [yoshinorim/mha4mysql-manager on GitHub](https://github.com/yoshinorim/mha4mysql-manager)
