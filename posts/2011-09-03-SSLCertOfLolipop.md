---
layout: post
title: SSLCertOfLolipop
date: 2011-09-03 01:41:19 +0900
---


[FFFTP開発終了で大騒ぎしている人たちへ](http://blog2.or6.jp/ftpisdead) にて、

	
	SSL証明書がまともなものでないと接続時にエラーが出るのですが、ロリポップなんかだと
	このエラーを無視するように公式ドキュメントに書いてあるので、かなり悪質です。
	

と書かれていますので、これについて説明させて頂きます。

この方が指摘されているのは、~~[Win FileZillaの設定 / ホームページ / マニュアル - ロリポップ！](http://lolipop.jp/manual/hp/w-fz/) ~~(FileZilla非推奨のため現在は削除されています)の中の、

	
	 証明書の確認を行います。『今後もこの証明書を常に信用する(A)』にチェックを入れて、『OK』をクリックします。
	

という部分だと思われるのですが、確かに、無条件で信用するにチェックを入れるようお客様に指示するのは大変良くないですね。

ロリポップでは [DigiCert Inc社](http://www.digicert.ne.jp/) によって発行されている証明書を利用しているのですが、Filezillaでは警告が出てしまうようです。

調べてみたところ、FilezillaはルートCAの証明書を保持しておらず、どのような証明書であっても、ユーザが「信用する」にチェックを入れなければ警告が出る仕様となっているようです。

[how to install root CA certificate on Filezilla](http://forum.filezilla-project.org/viewtopic.php?f=2&t=20767)

OR6 blog 様のご指摘により、このような証明書の検証をきちんと行っていないソフトウェアをお客様に推奨すべきではないと判断いたしましたので、Windows/Mac版ともに存在し、証明書の検証をきちんと行っている [Cyberduck](http://cyberduck.ch/) を推奨するよう、マニュアルを変更させて頂くことになりました。

また、蛇足ですが、ロリポップの [チカッパプラン](http://lolipop.jp/service/plan-chicappa/) では SSH サービスを提供していますので、FTPS の代わりに SCP/SFTP もご利用頂けます。

OR6 blog 様、この度はご指摘誠にありがとうございました。
