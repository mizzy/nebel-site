---
title: Sqale + Route 53 で Naked Domain を割り当てる方法
date: 2012-11-05 22:46:30 +0900
---
ペパボ が提供する PaaS [Sqale](http://sqale.jp) では ELB を利用しているため、Sqale 上でホストしているアプリに独自ドメインを割り当てる場合には CNAME を利用する必要があり、Naked Domain（ホスト名がないドメイン）を割り当てることができません。

Amazon Route 53 が持つ A レコードの Alias 機能を利用すれば、Naked Domain の割り当ても可能になりますが、自分の管理下ではない ELB がターゲットとなるため、もし Sqale 側で ELB の再作成が行われたりすると、新たな ELB の FQDN を調べて、Alias レコードを更新する必要があり、対応が面倒です。（そもそも、ELB が再作成されても気づけない可能性が高い。）

そこで以下のような、自動で Alias レコードを追加・修正するスクリプトを作成してみました。これを cron などで定期的に実行すれば、万が一 Sqale 側で ELB が再作成された場合でも、自動的に新しい ELB をターゲットとするようレコードを更新してくれます。（ご利用は自己責任でお願いします。）

使い方は以下の通りです。

 * SQALE_DOMAIN に割り当てられた sqale.jp のサブドメインを指定
 * ORIGINAL_DOMAIN に割り当てたい Naked Domain を指定
 * 環境変数 AWS_ACCESS_KEY, AWS_SECRET_KEY に、AWS のアクセスキーと秘密キーを指定


{% gist 4016041 update-route-53-alisa-for-sqale.rb %}
