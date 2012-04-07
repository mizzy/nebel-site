---
layout: post
title: BindDlzVsPowerDns
date: 2010-01-22 01:20:16 +0900
---


とある IRC チャネルで DNS ソフトウェアの話になって、当然 BIND や djbdns があがってくるわけなんですが、うち PowerDNS つかってて、ベンチマークとった資料とかあるよ、と言ったら、あんま事例ないと思うのでブログで公開するとうれしい人が多いかも、と [Ficia](http://ficia.com/) を [アツく語る人](http://d.hatena.ne.jp/hirose31/) から言われたので公開します。2年ちょいぐらい前につくった資料で、細かいこと忘れちゃってますし、社内向けに書いたものを公開するので、マズいところは省いたりしてます。

まずは VM 環境で、BIND + DLZ と PowerDNS（どちらもバックエンドに MySQL を使用）のパフォーマンス比較した資料を公開します。


# BIND + DLZ のパフォーマンス

## /etc/named.conf

	
	dlz "Mysql zone" {
	   database "mysql
	   {host=localhost dbname=dns_data ssl=false}
	   {select zone from dns_records where zone = '%zone%'}
	   {select ttl, type, mx_priority, case when lower(type)='txt' then concat('\"', data, '\"')
	        else data end from dns_records where zone '%record%'
	        and not (type 'NS')}
	   {select ttl, type, mx_priority, data, resp_person, serial, refresh, retry, expire, minimum
	        from dns_records where zone 'SOA' or type='NS')}
	   {select ttl, type, host, mx_priority, data, resp_person, serial, refresh, retry, expire,
	        minimum from dns_records where zone 'SOA' or type = 'NS')}
	   {select zone from xfr_table where zone '%client%'}
	   {update data_count set count '%zone%'}";
	};
	

## MySQLに登録された DNS レコード

	
	mysql> select * from dns_records;
	+-------------+------+------+--------------+-------+-------------+---------+-------+---------+---------+----------+-------------------+------------+
	| zone        | host | type | data         | ttl   | mx_priority | refresh | retry | expire  | minimum | serial   | resp_person       | primary_ns |
	+-------------+------+------+--------------+-------+-------------+---------+-------+---------+---------+----------+-------------------+------------+
	| example.org | @    | SOA  | localhost.   | 86400 | 10          |    3600 |   200 | 3600000 |    3600 | 20070919 | test.example.org. | NULL       |
	| example.org | www  | A    | 192.168.32.1 |  NULL | NULL        |    NULL |  NULL |    NULL |    NULL |     NULL | NULL              | NULL       |
	| example.org | abc  | A    | 192.168.32.2 |  NULL | NULL        |    NULL |  NULL |    NULL |    NULL |     NULL | NULL              | NULL       |
	| example.org | test | A    | 192.168.32.3 |  NULL | NULL        |    NULL |  NULL |    NULL |    NULL |     NULL | NULL              | NULL       |
	+-------------+------+------+--------------+-------+-------------+---------+-------+---------+---------+----------+-------------------+------------+
	

## dns_records テーブルのインデックスの状態

	
	mysql> show index from dns_records;
	+-------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+
	| Table       | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment |
	+-------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+
	| dns_records |          1 | host_index |            1 | host        | A         |        NULL |       20 | NULL   | YES  | BTREE      |         |
	| dns_records |          1 | zone_index |            1 | zone        | A         |        NULL |       30 | NULL   | YES  | BTREE      |         |
	| dns_records |          1 | type_index |            1 | type        | A         |        NULL |        8 | NULL   | YES  | BTREE      |         |
	+-------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+
	

## queryperf 用ファイル

	
	test.example.org A
	

## queryperf の実行結果

	
	# queryperf -d ~/dlz_test.dat -s 127.0.0.1 -l 10
	
	DNS Query Performance Testing Tool
	Version: $Id: queryperf.c,v 1.8.192.3 2005/10/29 00:21:12 jinmei Exp $
	
	[Status] Processing input data
	[Status] Sending queries (beginning with 127.0.0.1)
	[Status] Testing complete
	
	Statistics:
	
	  Parse input file:     multiple times
	  Run time limit:       10 seconds
	  Ran through file:     974 times
	
	  Queries sent:         975 queries
	  Queries completed:    975 queries
	  Queries lost:         0 queries
	  Queries delayed(?):   0 queries
	
	  RTT max:              2.775003 sec
	  RTT min:              0.043778 sec
	  RTT average:          0.253777 sec
	  RTT std deviation:    0.335064 sec
	  RTT out of range:     0 queries
	
	  Percentage completed: 100.00%
	  Percentage lost:        0.00%
	
	  Started at:           Thu Sep 20 19:38:22 2007
	  Finished at:          Thu Sep 20 19:38:35 2007
	  Ran for:              12.619786 seconds
	
	  Queries per second:   77.259630 qps
	

----

# PowerDNS のパフォーマンス

## MySQL に登録された DNS レコード

	
	mysql> select * from records;
	+----+-----------+--------------------+------+-------------------------+-------+------+-------------+
	| id | domain_id | name               | type | content                 | ttl   | prio | change_date |
	+----+-----------+--------------------+------+-------------------------+-------+------+-------------+
	|  1 |         1 | test.com           | SOA  | localhost ahu@ds9a.nl 1 | 86400 | NULL |        NULL |
	|  2 |         1 | test.com           | NS   | dns-us1.powerdns.net    | 86400 | NULL |        NULL |
	|  3 |         1 | test.com           | NS   | dns-eu1.powerdns.net    | 86400 | NULL |        NULL |
	|  4 |         1 | www.test.com       | A    | 199.198.197.196         |   120 | NULL |        NULL |
	|  5 |         1 | mail.test.com      | A    | 195.194.193.192         |   120 | NULL |        NULL |
	|  6 |         1 | localhost.test.com | A    | 127.0.0.1               |   120 | NULL |        NULL |
	|  7 |         1 | test.com           | MX   | mail.test.com           |   120 |   25 |        NULL |
	+----+-----------+--------------------+------+-------------------------+-------+------+-------------+
	

## records テーブルのインデックスの状態

	
	mysql> show index from records;
	+---------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+
	| Table   | Non_unique | Key_name       | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment |
	+---------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+
	| records |          0 | PRIMARY        |            1 | id          | A         |           7 |     NULL | NULL   |      | BTREE      |         |
	| records |          1 | rec_name_index |            1 | name        | A         |           7 |     NULL | NULL   | YES  | BTREE      |         |
	| records |          1 | nametype_index |            1 | name        | A         |           7 |     NULL | NULL   | YES  | BTREE      |         |
	| records |          1 | nametype_index |            2 | type        | A         |           7 |     NULL | NULL   | YES  | BTREE      |         |
	| records |          1 | domain_id      |            1 | domain_id   | A         |           2 |     NULL | NULL   | YES  | BTREE      |         |
	+---------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+
	

## queryperf 用設定ファイルの内容

	
	www.test.com A
	

## queryperf の実行結果

	
	# queryperf -d ~/pdns_test.dat -s 127.0.0.1 -l 10
	
	DNS Query Performance Testing Tool
	Version: $Id: queryperf.c,v 1.8.192.3 2005/10/29 00:21:12 jinmei Exp $
	
	[Status] Processing input data
	[Status] Sending queries (beginning with 127.0.0.1)
	[Status] Testing complete
	
	Statistics:
	
	  Parse input file:     multiple times
	  Run time limit:       10 seconds
	  Ran through file:     42159 times
	
	  Queries sent:         42160 queries
	  Queries completed:    42160 queries
	  Queries lost:         0 queries
	  Queries delayed(?):   0 queries
	
	  RTT max:              0.013259 sec
	  RTT min:              0.000331 sec
	  RTT average:          0.002268 sec
	  RTT std deviation:    0.001248 sec
	  RTT out of range:     0 queries
	
	  Percentage completed: 100.00%
	  Percentage lost:        0.00%
	
	  Started at:           Thu Sep 20 19:36:47 2007
	  Finished at:          Thu Sep 20 19:36:57 2007
	  Ran for:              10.000367 seconds
	
	  Queries per second:   4215.845278 qps
	

----

# 結論

BIND + DLZ: 77.259630 qps、PowerDNS: 4215.845278 qps で PowerDNS の圧勝。これは BIND + DLZ がリクエスト毎に MySQL 問い合わせしてるのに対し、PowerDNS はメモリにキャッシュしていちいち MySQL に問い合わせないから、だろう。
