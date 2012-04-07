---
layout: post
title: ModSuid2AndModRuidAndLinuxCapability
date: 2007-10-28 01:45:53 +0900
---


Apache の suEXEC では setuid/setgid を使って、httpd 実行ユーザとは異なるユーザ権限で CGI プログラムや SSI プログラムを実行できるわけですが、mod_php で処理される PHP プログラムのように、httpd 内で処理されるプログラムは、httpd 実行ユーザの権限で実行されてしまいます。こういったものまで httpd とは異なるユーザ権限で実行するためのモジュールとして、[mod_suid2](http://bluecoara.net/download/mod_suid2/) や [mod_ruid](http://websupport.sk/~stanojr/projects/mod_ruid/) といったものがあります。

mod_suid2 は、httpd を root で起動しておいて、リクエストに応じて（VirtualHost 単位等で）setuid/setgid して実行ユーザを切り替える、という動作をします。そのため、以下のような問題があります。

* -DBIG_SECURITY_HOLE つきで Apache をコンパイルする必要がある。
* root でプロセスを起動する危険性。
* MaxRequestsPerChild が 1 に設定されることによるパフォーマンスの劣化。（一度 setuid/setgid してしまうと、root ではなくなり setuid/setgid できなくなるので、リクエストを処理するたびにプロセス/スレッドを殺す必要があるため）

これに対し、mod_ruid は Linux に実装されている POSIX 1003.1e で定義された[ケーパビリティ](http://opentechpress.jp/security/03/08/06/0941214.shtml) を利用して、root で httpd を起動することなく、setuid/segid できる権限のみ与えて、プロセス/スレッドの実行ユーザを切り替えています。そのため、mod_suid2 が抱える問題点の多くを解消しています。（また、mod_suid2 と違い、参照するファイルやディレクトリのユーザ/グループに実行権限を切り替える機能もあります。）

ここで気になったのは、「setuid/setgid って、プロセス単位じゃなくてスレッド単位でもできるの？」ということ。もしできないのであれば、worker ではなく prefork で動かす必要もある、ということになる。で、結論からいうと「できる」でした。[マルチスレッドのコンテキスト切り替えに伴うコスト - naoyaのはてなダイアリー](http://d.hatena.ne.jp/naoya/20071010/1192040413) をご覧になると分かるように、スレッドを生成する毎に dup_task_struct(current) して、各スレッドが個別にプロセスディスクリプタを持つので、当然と言えば当然なのですが、mod_ruid を有効にした Apache のプロセス状態を表示することによって、スレッドごとに実行ユーザがちゃんと異なっていることを確認しました。（mod_ruid はリクエスト処理後に元のユーザに戻してしまうため、確認のため戻さないようにソースを少しいじってます。）

	
	$ ps -efL
	UID        PID  PPID   LWP  C NLWP STIME TTY          TIME CMD 
	daemon    4156  4153  4188  0   27 20:48 ?        00:00:00 /usr/local/apache2/bin/httpd -k start 
	miya      4156  4153  4189  0   27 20:48 ?        00:00:00 /usr/local/apache2/bin/httpd -k start
	puppet    4156  4153  4225  0   27 20:48 ?        00:00:00 /usr/local/apache2/bin/httpd -k start
	

ちなみに、Linux での setuid の処理は、kernel/sys.c で以下のようになっています。

	
	#!c
	asmlinkage long sys_setuid(uid_t uid)
	{
		int old_euid = current->euid;
		int old_ruid, old_suid, new_suid;
		int retval;
	
		retval = security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_ID);
		if (retval)
			return retval;
	
		old_ruid = current->uid;
		old_suid = current->suid;
		new_suid = old_suid;
		
		if (capable(CAP_SETUID)) {
			if (uid != old_ruid && set_user(uid, old_euid != uid) < 0)
				return -EAGAIN;
			new_suid = uid;
		} else if ((uid != current->uid) && (uid != new_suid))
			return -EPERM;
	
		if (old_euid != uid) {
			set_dumpable(current->mm, suid_dumpable);
			smp_wmb();
		}
		current->fsuid uid;
		current->suid = new_suid;
	
		key_fsuid_changed(current);
		proc_id_connector(current, PROC_EVENT_UID);
	
		return security_task_post_setuid(old_ruid, old_euid, old_suid, LSM_SETID_ID);
	}
	

task_struct 構造体の、fsuid, euid, suid あたりを書き換えているようですね。

まとまりのないエントリになってしまいましたが、ケーパビリティとか、スレッド単位で setuid/setgid できるとか、はじめて知ることが多かったのでとりあえずメモ。
