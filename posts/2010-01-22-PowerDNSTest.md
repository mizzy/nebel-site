---
layout: post
title: PowerDNSTest
date: 2010-01-22 01:44:00 +0900
---


[wiki:BindDlzVsPowerDns 前回のエントリ] のつづき。今度は BIND + DLZ との比較ではなく、PowerDNS 単体、実サーバ上でパフォーマンス測定したり、長時間負荷かけてみたり、更新かつキャッシュパージしながら参照したり、といったテストをした時の記録。こちらもやはり2年ちょいぐらい前に作ったモノ。

----

[[PageOutline(2-4, 目次, inline)]]

----

# テスト環境について

* DNSサーバ
   * AMD Athlon(tm) 64 X2 Dual Core Processor 4600+
   * 2GB メモリ
* MySQLサーバ
   * AMD Athlon(tm) 64 X2 Dual Core Processor 4600+
   * 2GB メモリ
* テスト用 DNS クライアント
   * AMD Athlon(tm) 64 X2 Dual Core Processor 4600+
   * 2GB メモリ

----

# テストデータの投入

## テスト用ゾーンデータを SQL 形式で準備

具体的なデータは大人の事情で省略。ゾーン数が26万、レコード数が280万ほど。バックエンドが MySQL なので、SQL 形式でデータを準備。


## SQL データを MySQL へ投入

	
	$ time mysql --disable-pager -uroot -f pdns < zone.sql 2> err.log
	real    54m56.423s
	user    0m30.502s
	sys     0m32.974s
	

投入後のレコード数を見てみる。

	
	mysql> select count(*) from domains;
	+----------+
	| count(*) |
	+----------+
	|   263238 |
	+----------+
	1 row in set (0.14 sec)
	
	mysql> select count(*) from records;
	+----------+
	| count(*) |
	+----------+
	|  2798571 |
	+----------+
	


データベースディレクトリのサイズ。

	
	# cd /var/lib/mysql
	# du -sk
	726304  .
	

----

# queryperf 用データ生成

以下のようなスクリプトで、BIND ゾーンファイルからデータファイルを生成。

	
	#!perl
	#!/usr/bin/perl
	
	use strict;
	use warnings;
	use Path::Class;
	
	my $dir = shift or die "usage : $0 <dir>\n";
	
	dir($dir)->recurse(
	    callback => sub {
	        my $file = shift;
	        return if $file !~ m{.+/([^/]+)\.zone$};
	        my $zone = $1;
	
	        open my $fh, '<', $file or die $!;
	        while ( <$fh> ) {
	            if ( $_ =~ /([^\s]*)\s+(A|MX|CNAME)\s+(.+)$/ ) {
	                my $domain = $1 ? "$1.$zone" :  $zone;
	                my $type   = $2;
	                my $value  = $3;
	
	                $value =~ s/^\d+\s+// if $type eq 'MX';
	
	                print "$domain $type\n";
	            }
	        }
	    }
	);
	
	exit;
	

データファイルの内容は、こんな感じ。これが 2,517,990 行ある。

	
	example.com A
	example.com MX
	www.example.com A
	ftp.example.com
	example.jp A
	example.jp MX
	www.example.jp A
	ftp.example.jp
	...
	


----

# 参照負荷/パフォーマンステスト

## 負荷のかけかた/パフォーマンス測定方法

負荷をかけるのとパフォーマンスを測定するのは、BIND 付属の queryperf コマンドを利用。queryperf コマンドは、上記で生成した大量負荷用データファイル内のレコードに対するクエリを、上から順番に実行していく。


## 負荷をかける前のプロセスの状態

起動直後（何もキャッシュしていない状態）の pdns_server プロセスの状態。

	
	$ ps aux
	USER       PID %CPU %MEM   VSZ   RSS   TTY      STAT START   TIME COMMAND
	root     31715  0.0  0.0 16556 1212 ?        Ssl  11:03   0:00 /usr/local/sbin/pdns_server --daemon --guardian=yes
	root     31717  0.2  0.1 88688 2660 ?        Sl   11:03   0:00 /usr/local/sbin/pdns_server-instance --daemon --guardian=yes
	

* 実際に処理を担当し、プロセスをキャッシュする（と思われる）子プロセスの仮想メモリサイズは約 90M。


## 大量/長時間負荷をかけた場合の安定度

5時間にわたって負荷をかけつづけた結果。

	
	$ queryperf -s 192.168.50.43 -d queryperf.dat -l 19800
	
	DNS Query Performance Testing Tool
	Version: $Id: queryperf.c,v 1.8.192.3 2005/10/29 00:21:12 jinmei Exp $
	
	[Status] Processing input data
	[Status] Sending queries (beginning with 192.168.50.43)
	[Status] Testing complete
	
	Statistics:
	
	  Parse input file:     multiple times
	  Run time limit:       19800 seconds
	  Ran through file:     43 times
	
	  Queries sent:         110458827 queries
	  Queries completed:    110454675 queries
	  Queries lost:         4152 queries
	  Queries delayed(?):   0 queries
	
	  RTT max:              0.820253 sec
	  RTT min:              0.000053 sec
	  RTT average:          0.003381 sec
	  RTT std deviation:    0.045216 sec
	  RTT out of range:     0 queries
	
	  Percentage completed: 100.00%
	  Percentage lost:        0.00%
	
	  Started at:           Thu Sep 27 02:11:58 2007
	  Finished at:          Thu Sep 27 07:42:01 2007
	  Ran for:              19803.489895 seconds
	
	  Queries per second:   5577.535858 qps
	

この時の pdns_server プロセスの仮想メモリサイズ。

	
	USER       PID %CPU %MEM   VSZ   RSS   TTY      STAT START   TIME COMMAND
	root     28130  0.0  0.0 15464  1212   ?        Ssl  02:11   0:00 /usr/local/sbin/pdns_server --daemon --guardian=yes
	root     28132 65.2 20.7 550480 427176 ?     Sl   02:11 329:49 /usr/local/sbin/pdns_server-instance --daemon --guardian=yes
	


* この状態で全レコードをキャッシュしている模様（MySQLの負荷がまったくない状態になってる）
* 200万以上のレコードをすべてキャッシュしても、pdns_serverプロセスの仮想メモリサイズは 550M ほど。
* 5577クエリ/秒を5時間続けても、安定して動いている。
* 大量クエリ発行中に、別のところから dig を叩いても、すぐにレスポンスが返る。
* 結論としては、5000クエリ/秒のパフォーマンスを長時間安定して出すことができている、と言えそう。


## 1件のレコードのみを繰り返し検索した場合のパフォーマンス（ローカル）

example.jp の A レコードを queryperf で localhost に対してひたすら問い合わせ。メモリには1件だけキャッシュされた状態となる。

これにより [wiki:BindDlzVsPowerDns VM環境でのテスト] と比較してみる。

	
	$ queryperf -s localhost -d 1record.dat -l 10
	
	DNS Query Performance Testing Tool
	Version: $Id: queryperf.c,v 1.8.192.3 2005/10/29 00:21:12 jinmei Exp $
	
	[Status] Processing input data
	[Status] Sending queries (beginning with 127.0.0.1)
	[Status] Testing complete
	
	Statistics:
	
	  Parse input file:     multiple times
	  Run time limit:       10 seconds
	  Ran through file:     523722 times
	
	  Queries sent:         523723 queries
	  Queries completed:    523723 queries
	  Queries lost:         0 queries
	  Queries delayed(?):   0 queries
	
	  RTT max:              0.000850 sec
	  RTT min:              0.000075 sec
	  RTT average:          0.000348 sec
	  RTT std deviation:    0.000006 sec
	  RTT out of range:     0 queries
	
	  Percentage completed: 100.00%
	  Percentage lost:        0.00%
	
	  Started at:           Thu Sep 27 12:34:52 2007
	  Finished at:          Thu Sep 27 12:35:02 2007
	  Ran for:              10.000307 seconds
	
	  Queries per second:   52370.692220 qps
	

VM環境でのテストでは、約4000クエリ/秒なので、10倍以上のパフォーマンス。


## 1件のレコードのみを繰り返し検索した場合のパフォーマンス（リモート）

ローカルの場合と同じく、example.jp の A レコードを今度はネットワーク越しにひたすら参照して比較してみる。

	
	$ queryperf -s 192.168.50.43 -d 1record.dat -l 10
	
	DNS Query Performance Testing Tool
	Version: $Id: queryperf.c,v 1.8.192.3 2005/10/29 00:21:12 jinmei Exp $
	
	[Status] Processing input data
	[Status] Sending queries (beginning with 192.168.50.43)
	[Timeout] Query timed out: msg id 18924
	[Status] Testing complete
	
	Statistics:
	
	  Parse input file:     multiple times
	  Run time limit:       10 seconds
	  Ran through file:     390784 times
	
	  Queries sent:         390785 queries
	  Queries completed:    390784 queries
	  Queries lost:         1 queries
	  Queries delayed(?):   0 queries
	
	  RTT max:              1.677650 sec
	  RTT min:              0.000075 sec
	  RTT average:          0.000454 sec
	  RTT std deviation:    0.002683 sec
	  RTT out of range:     0 queries
	
	  Percentage completed: 100.00%
	  Percentage lost:        0.00%
	
	  Started at:           Thu Sep 27 12:38:04 2007
	  Finished at:          Thu Sep 27 12:38:16 2007
	  Ran for:              12.191577 seconds
	
	  Queries per second:   32053.605534 qps
	

ローカルに比べると、32053 / 52370 = 約60% ほどにパフォーマンスがおちる。


## 全レコードをキャッシュした状態でのパフォーマンス

長時間クエリを走らせて、すべてのクエリをキャッシュさせた状態でパフォーマンスを計測。

	
	$ queryperf -s 192.168.50.43 -d ./queryperf.dat -l 10
	
	DNS Query Performance Testing Tool
	Version: $Id: queryperf.c,v 1.8.192.3 2005/10/29 00:21:12 jinmei Exp $
	
	[Status] Processing input data
	[Status] Sending queries (beginning with 192.168.50.43)
	[Status] Testing complete
	
	Statistics:
	
	  Parse input file:     multiple times
	  Run time limit:       10 seconds
	  Ran through file:     0 times
	
	  Queries sent:         60000 queries
	  Queries completed:    60000 queries
	  Queries lost:         0 queries
	  Queries delayed(?):   0 queries
	
	  RTT max:              0.734255 sec
	  RTT min:              0.000214 sec
	  RTT average:          0.003470 sec
	  RTT std deviation:    0.046068 sec
	  RTT out of range:     0 queries
	
	  Percentage completed: 100.00%
	  Percentage lost:        0.00%
	
	  Started at:           Thu Sep 27 12:22:15 2007
	  Finished at:          Thu Sep 27 12:22:25 2007
	  Ran for:              10.448189 seconds
	
	  Queries per second:   5742.621999 qps
	

『1件のレコードのみを繰り返し検索した場合のパフォーマンス（リモート）』と比較して、5742 / 32053 = 17% ほどにパフォーマンスが落ちる。（約1/6）

データ量が 2,500,000 倍で、パフォーマンスが 1/6 は数値としてはかなり優秀だと思う。これについて軽く考察してみる。

例えば、大量データの探索によく使われている二分木構造でレコードが管理されていると仮定した場合、250万レコード登録されていると、目的のレコードを探し当てるまでのツリーの探索回数は、最大で22回、平均で20回となる。

したがって、バイナリツリーでレコードが管理されていると想定した場合には、レコード数が 1 から 2,500,000 に増えれば、パフォーマンスは理論的には 1/20 に落ちる、ということになる。これが 1/6 程度に抑えられているので、大量にキャッシュを保持した状態でも、かなり高いパフォーマンスを実現している、と言えるのではないかと。


また、同様のパフォーマンステストをネットワーク越しではなくローカルで実行してみると、以下の様になった。

	
	$ queryperf -s localhost -d queryperf.dat -l 10
	
	DNS Query Performance Testing Tool
	Version: $Id: queryperf.c,v 1.8.192.3 2005/10/29 00:21:12 jinmei Exp $
	
	[Status] Processing input data
	[Status] Sending queries (beginning with 127.0.0.1)
	[Status] Testing complete
	
	Statistics:
	
	  Parse input file:     multiple times
	  Run time limit:       10 seconds
	  Ran through file:     0 times
	
	  Queries sent:         60005 queries
	  Queries completed:    60005 queries
	  Queries lost:         0 queries
	  Queries delayed(?):   0 queries
	
	  RTT max:              0.738513 sec
	  RTT min:              0.000142 sec
	  RTT average:          0.003365 sec
	  RTT std deviation:    0.045920 sec
	  RTT out of range:     0 queries
	
	  Percentage completed: 100.00%
	  Percentage lost:        0.00%
	
	  Started at:           Thu Sep 27 13:47:33 2007
	  Finished at:          Thu Sep 27 13:47:43 2007
	  Ran for:              10.134120 seconds
	
	  Queries per second:   5921.086389 qps
	

これを『1件のレコードのみを繰り返し検索した場合のパフォーマンス（ローカル）』と比較してみる。こちらの方がネットワークのボトルネックを考慮しなくて良いので、より正確なパフォーマンス劣化具合が見られる。

ローカルの場合には、5930 / 52370 = 約 1/10 となる。これでもなお理論値の 1/20 よりは高いパフォーマンスが出ている。


 
## 全レコードの半分ほどをキャッシュした状態でのパフォーマンス

参考までに、キャッシュで保持しているデータを半分ほどにした時のパフォーマンスを見るために、pdns_server プロセスの仮想メモリサイズが 300M ほどの状態でパフォーマンスを測定してみた。

	
	$ queryperf -s 192.168.50.43 -d ./mizzy/queryperf.dat -l 10
	
	DNS Query Performance Testing Tool
	Version: $Id: queryperf.c,v 1.8.192.3 2005/10/29 00:21:12 jinmei Exp $
	
	[Status] Processing input data
	[Status] Sending queries (beginning with 192.168.50.43)
	[Timeout] Query timed out: msg id 53362
	[Status] Testing complete
	
	Statistics:
	
	  Parse input file:     multiple times
	  Run time limit:       10 seconds
	  Ran through file:     0 times
	
	  Queries sent:         92879 queries
	  Queries completed:    92878 queries
	  Queries lost:         1 queries
	  Queries delayed(?):   0 queries
	
	  RTT max:              0.428813 sec
	  RTT min:              0.000076 sec
	  RTT average:          0.002126 sec
	  RTT std deviation:    0.025852 sec
	  RTT out of range:     0 queries
	
	  Percentage completed: 100.00%
	  Percentage lost:        0.00%
	
	  Started at:           Thu Sep 27 12:28:24 2007
	  Finished at:          Thu Sep 27 12:28:35 2007
	  Ran for:              10.894836 seconds
	
	  Queries per second:   8524.956227 qps
	

当然だけどパフォーマンスは上がってる。

----

# 大量更新テスト

以下の内容を実行するテスト用スクリプトを作成。

1. queryperf 用データファイルからレコードを1件読み取る
1. 対象レコードを DNS 参照してキャッシュに載せる。
1. 対象レコードの変更を MySQL に対して行う。
1. 対象レコードを DNS 参照する。この時点ではキャッシュのクリアを行っていないため、変更前の値が返ってくることを確認する。
1. ssh 経由で「pdns_control purge レコード名」を実行して、対象レコードのキャッシュをクリア、
1. 対象レコードを DNS 参照する。キャッシュがクリアされているはずなので、変更後の値が返ってくることを確認する。
1. 最初に戻って繰り返す。

これを queryperf で参照系の負荷をかけながら行う。

スクリプトの内容は以下の通り。

	
	#!perl
	#!/usr/bin/perl
	
	use strict;
	use warnings;
	use DBI;
	use Net::DNS;
	use Test::More qw( no_plan );
	
	#my $file  = shift;
	my $file = 'queryperf.dat';
	
	my $limit = 1000;
	
	my $dsn      = 'DBI:mysql:pdns:192.168.50.44';
	my $user     = 'pdns';
	my $password = 'pdns';
	my $dbh      = DBI->connect($dsn, $user, $password);
	
	my %method_hash = (
	    A     => 'address',
	    MX    => 'exchange',
	    CNAME => 'cname',
	);
	
	my $count    = 0;
	my $resolver > [ '192.168.50.43' ] );
	
	srand time;
	
	open my $fh, '<', $file or die $!;
	while ( <$fh> ) {
	
	    my ( $domain, $type ) ~ /^([^\s]+)\s+(A|MX|CNAME)/ );
	    $type ||= 'A';
	
	    # DNS参照してキャッシュに載せる
	    my $res = $resolver->query($domain, $type);
	    my $method = $method_hash{$type};
	    my $answer = ($res->answer)[0]->$method;
	
	    # DBを書き換える
	    my $sth    ? WHERE name ?');
	    my $update = generate_random_value($domain, $type);
	    $sth->execute($update, $domain, $type);
	
	    # DNS参照して、古いデータが返ってくることを確認する
	    $res = $resolver->query($domain, $type);
	    is( ($res->answer)[0]->$method, $answer);
	
	    # キャッシュをpurgeする
	    system "ssh 192.168.50.43 sudo pdns_control purge $domain";
	
	    # DNS参照して、新しいデータが返ってくることを確認する
	    $res = $resolver->query($domain, $type);
	    is( ($res->answer)[0]->$method, $update);
	
	    last if $count > $limit;
	    $count++;
	}
	
	close $fh;
	
	exit;
	
	sub generate_random_value {
	    my $domain = shift;
	    my $type   = shift;
	
	    if ( $type eq 'A' ) {
	        my $a1 = int rand 255 + 1;
	        my $a2 = int rand 255 + 1;
	        my $a3 = int rand 255 + 1;
	        my $a4 = int rand 255 + 1;
	
	        return "$a1.$a2.$a3.$a4";
	    }
	    else {
	        return crypt( ( rand 100000 ), 'AA' ) . ".$domain";
	    }
	}
	


queryperf で参照負荷をかけながら1000 回ループを繰り返してみたところ、キャッシュのクリアができずに古いレコードが返ってくる、というケースは 0 件だった。ただし、レコード変更後に、キャッシュをクリアする前に新しいレコードが返ってくる、というケースが 20 件あった。おそらく負荷等の問題でうまくキャッシュに載らなかったためと思われるが、この場合でも新しいレコードが取得できていたので、特に問題はないと判断。

というわけで、レコードの更新とキャッシュのクリアはまったく問題なし。（後日10,000回ループを繰り返したが、こちらも問題なかった。）
