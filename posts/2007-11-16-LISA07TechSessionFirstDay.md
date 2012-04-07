---
layout: post
title: LISA07TechSessionFirstDay
date: 2007-11-16 07:09:21 +0900
---
現在、[LISA](http://www.usenix.org/events/lisa07/) という大規模システム管理者向けカンファレンスへの参加のため、ダラスに来ています。自分は 11/14 - 11/16 に開催されるテクニカルセッションのみに参加していて、本日はテクニカルセッションの初日でした。今日聞いた中で気になったテーマについて、さらっとご紹介、というか自分用にまとめてみます。


# CAMP: A Common API for Measuring Performance

名前の通り、パフォーマンス計測のための API。異なる OS が混在する分散システムでのパフォーマンステストを正確に行うために、共通な API を定義しよう、という試み。

[概要はこちら](http://www.usenix.org/events/lisa07/tech/gabel.html)。ここから論文すべて（HTML or PDF）を参照できる。（2008年11月までは、USENIX メンバーじゃないとアクセスできない、と書いてあるけど、アクセス制限はかかってないみたい。いいのかな？）

CAMP は Python で実装されていて、以下のようなコードでパフォーマンスデータが取得できる。

	
	#!python
	# Calculate the current transfer rate (Both
	# in and out) for the given network adapter.
	def BulkByteTransferRate(adapter):
	    # Query CAMP for the initial state.
	    initial = GetNetBytesSent(adapter)
	    initial += GetNetBytesRecvd(adapter)
	    time.sleep(SAMPLE_INTERVAL)
	    # Query CAMP for the final state.
	    final = GetNetBytesSent(adapter)
	    final += GetNetBytesRecvd(adapter)
	    return (final - initial)/SAMPLE_INTERVAL
	

GetNetBytesSent や GetNetBytesRecvd が CAMP によって提供されているメソッド。

現在対応している OS は、

* Linux 2.6
* Win32 (Windows NT/2000/XP)
* Solaris (SunOS kernel 5.x)

の3種類。パフォーマンスデータの取得は、Linux では proc、Windows では Microsoft's performance data handler (PDH) interface、Solaris では proc と kstat を利用しているとのこと。

論文の中では、CAMP によって取得できるパフォーマンスデータの妥当性に関する検証や、CAMP 自体のパフォーマンス、オーバーヘッドに関する検証データも載っている。

proc ファイルシステムへのアクセスオーバヘッドの低さから、特に Linux でのパフォーマンスは高いみたい。

パフォーマンスデータを取得するのであれば、SNMP でもできるのでは、と思ったけど、これについても論文でちゃんと触れられていて、SNMP は UDP によるアプリケーションプロトコルであり、CAMP を利用することで OS に依存しない SNMP エージェントを実装する、といった形での住み分けができる、といったことが書かれていた。

[CAMP の Trac サイト](http://wiki.csc.calpoly.edu/camp)が存在するけど、内容はまだ何もない。「** Download coming soon! **」ということなので、ソースが公開されたら要チェック。

# Application Buffer-Cache Management for Performance: Running the World’s Largest MRTG

OS のディスク I/O 先読みとバッファキャッシュは通常、アプリケーションのパフォーマンスを高めるものであるが、大規模ネットワークで MRTG を運用していると、逆にパフォーマンスを低下させてしまう、ということについて、何がボトルネックになっているのか、どうやってそのボトルネックを解消するのか、といったことに関する考察。[概要はこちら](http://www.usenix.org/events/lisa07/tech/plonka.html)。

まず、大規模ネットワークサイトでの MRTG の処理時間がグラフで示されている。これによると、5分おきに MRTG を実行しているにも関わらず、半分ほどの処理が5分以内に完了していない、という結果に。そして、MRTG のボトルネックはディスク I/O であり、特に read の比率が高い、ということが示されている。

MRTG は RRDtool を利用しているが、RRD ファイルは特性として、一度の操作で読み書きするブロックがシーケンシャルになっていない。そのため、OS がシーケンシャルにファイルを先読みすることによって、読み込む必要のないブロックまで読み込んでしまい、余分な I/O が発生する、ということがボトルネックの一因。いわゆる余計なお世話。

また、必要のないブロックを読み込んでバッファキャッシュに載せるため、キャッシュに本当に載せてほしいブロックが載らずに、ページフォルトが発生する、というのもボトルネックの一因。

この調査のために、[fincore](http://net.doit.wisc.edu/~plonka/fincore/) という、指定したファイルのどのページがバッファキャッシュに載っているのかを表示するツールを作っている。

ボトルネックを解消するアプローチのひとつは、独自のキャッシュライブラリを作成して、MRTG にこのライブラリ経由でファイル操作をさせる、というもの。これにより、ほとんどの処理が1分以内で完了するようになった。（ただし、キャッシュの処理は図を見るとちょっと複雑。）

もうひとつのアプローチは、アプリケーションのファイルアクセス特性を OS に伝えることによって、OS のディスクI/O に関する挙動を変えたり、キャッシュアルゴリズムを変えたり、といったことが可能な、[POSIX fadvise システムコール](http://docs.hp.com/ja/B2355-60129/fadvise.2.html)を利用して MRTG を動かす、というもの。

[fadvise を実行する Perl スクリプト](http://net.doit.wisc.edu/~plonka/fadvise/) も作成している。

論文では FADV_RANDOM を指定することによって、OS に対してアプリケーションが、シーケンシャルではなくランダムにファイルアクセスすることを伝えている。これにより OS は先読みをしなくなり余計なI/Oが発生しないし、余分なデータを読み込まないのでバッファキャッシュも無駄なく利用できる。（FADV_RANDOM という言葉は出てないけど、たぶんそうだと思う。）

このアプローチでもほとんどの処理が1分以内に完了する、という結果に。
