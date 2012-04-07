---
layout: post
title: SupervisorAProcessControlSystem
date: 2011-04-27 07:56:24 +0900
---
node.js なサーバデーモン＆ログの管理をしようと思い、何を使おうか検討していたのですが、この手のデファクトスタンダードである [daemontools](http://cr.yp.to/daemontools.html) は、特定のディレクトリ構造に従わないといけなかったり、run スクリプトや log/run スクリプトを置いたりしきゃいけなかったりで、余計な作業が多くてお手軽じゃない、ってことで [runit](http://smarden.org/runit/) を見てみたんですが、ぱっと見 daemontools との違いがよくわからなくて、daemontools とそれほど煩雑さは変わらないように見えたので、もっとお手軽なものがないかと探していたところ見つけたのが [Supervisor](http://supervisord.org/) 。（といっても自分が知らなかっただけで以前からあるみたいですが。）

Python 製で easy_install 一発でインストールできる。

	
	$ sudo easy_install supervisor  
	

デフォルトの設定ファイルを以下のように生成。

	
	$ sudo echo_supervisord_conf > /etc/supervisord.conf
	

あとは実行。とりあえず試しなので、-n をつけてフォアグラウンド起動。

	
	$ sudo supervisord -n
	2011-04-26 15:13:11,384 CRIT Supervisor running as root (no user in config file)
	2011-04-26 15:13:11,420 INFO RPC interface 'supervisor' initialized
	2011-04-26 15:13:11,421 CRIT Server 'unix_http_server' running without any HTTP authentication checking
	2011-04-26 15:13:11,421 INFO supervisord started with pid 25859
	

この状態ではデーモンを一切管理してない。で、/etc/supervisord.conf を覗くと、以下のような記述があって、どうやらこんな感じで管理するデーモンを設定するらしい。

	
	;[program:theprogramname]
	;command=/bin/cat              ; the program (relative uses PATH, can take args)
	;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
	;numprocs=1                    ; number of processes copies to start (def 1)
	;directory=/tmp                ; directory to cwd to before exec (def no cwd)
	;umask=022                     ; umask for process (default None)
	;priority=999                  ; the relative start priority (default 999)
	;autostart=true                ; start at supervisord start (default: true)
	;autorestart=true              ; retstart at unexpected quit (default: true)
	;startsecs=10                  ; number of secs prog must stay running (def. 1)
	;startretries=3                ; max # of serial start failures (default 3)
	;exitcodes=0,2                 ; 'expected' exit codes for process (default 0,2)
	;stopsignal=QUIT               ; signal used to kill process (default TERM)
	;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
	;user=chrism                   ; setuid to this UNIX account to run the program
	;redirect_stderr=true          ; redirect proc stderr to stdout (default false)
	;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
	;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
	;stdout_logfile_backups=10     ; # of stdout logfile backups (default 10)
	;stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
	;stdout_events_enabled=false   ; emit events on stdout writes (default false)
	;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
	;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
	;stderr_events_enabled=false   ; emit events on stderr writes (default false)
	;environment=A=1,B=2           ; process environment additions (def no adds)
	;serverurl=AUTO                ; override serverurl computation (childutils)
	

これを真似して、node.js な echo サーバをデーモン化してみた。最低限以下の設定を書けば OK。

	
	[program:echo]
	command=/usr/local/bin/node /home/miya/echo.js
	stdout_logfile=/var/log/echo.log
	stderr_logfile=/var/log/echo.log
	

これで起動してみる。

	
	$ sudo supervisord -n
	2011-04-26 15:22:05,577 CRIT Supervisor running as root (no user in config file)
	2011-04-26 15:22:05,612 INFO RPC interface 'supervisor' initialized
	2011-04-26 15:22:05,612 CRIT Server 'unix_http_server' running without any HTTP authentication checking
	2011-04-26 15:22:05,613 INFO supervisord started with pid 26078
	2011-04-26 15:22:06,621 INFO spawned: 'echo' with pid 26079
	2011-04-26 15:22:07,623 INFO success: echo entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
	

echo サーバがちゃんと起動した。こんな感じで、特定のディレクトリ構造にしたり、run スクリプト置いたりしなくても、4行ほど設定書くだけでさくっとデーモン化できる。試しに kill してみたら、再起動してくれた。

	
	2011-04-26 15:22:38,714 INFO exited: echo (exit status 1; not expected)
	2011-04-26 15:22:39,718 INFO spawned: 'echo' with pid 26122
	2011-04-26 15:22:40,720 INFO success: echo entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
	

include が使えるので、実運用ではデーモン毎にファイルをわけてやると管理しやすそう。

	
	;[include]
	;files = relative/directory/*.ini
	

supervisorctl というコマンドラインツールでステータス確認や起動/停止ができる。

	
	$ sudo supervisorctl status echo
	echo                             RUNNING    pid 26256, uptime 0:05:41
	
	$ sudo supervisorctl stop echo
	echo: stopped
	
	$ sudo supervisorctl start echo
	echo: started
	

何も引数を指定しなければ、対話型のインターフェースが起動する。

	
	$ sudo supervisorctl
	echo                             RUNNING    pid 26161, uptime 0:01:43
	supervisor> 
	

? で利用できるコマンド表示。

	
	supervisor> ?
	
	default commands (type help <topic>):
	=====================================
	add    clear  fg        open  quit    remove  restart   start   stop  update 
	avail  exit   maintail  pid   reload  reread  shutdown  status  tail  version
	

help command で command の説明。
	
	supervisor> help stop
	stop <name>		Stop a process
	stop <gname>:*		Stop all processes in a group
	stop <name> <name>	Stop multiple processes or groups
	stop all		Stop all processes
	

それから、デフォルトではオフになってるけど、HTTP のインタフェースもある。こんな感じでオンにしてやる。（とりあえず検証目的なのでユーザ名やパスワードは設定しない。）

	
	[inet_http_server]         ; inet (TCP) server disabled by default
	port=0.0.0.0:9001          ; (ip_address:port specifier, *:port for all iface)
	;username=user             ; (default is no username (open server))
	;password=123              ; (default is no password (open server))
	

ブラウザからアクセスするとこんな感じ。起動/停止やログの確認ができる。複数のデーモンを管理していれば、それらを一気に停止/起動もできるみたい。

[[Image(http://mizzy.org/img/supervisor.png)]]

supervisord 自体は、daemontools と同様、/etc/inittab とか、Upstart なら /etc/init/* とかで起動してやればいい。

いまいちなところは、multilog と違ってログにタイムスタンプつけてくれなかったり、syslog に吐く機能もなかったりと、ログまわりはちょっと物足りない。

他にも XML-RPC なインターフェースがあったり、色々機能はあるみたいなんだけど、とりあえず今日はこの辺で。
