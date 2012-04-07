---
layout: post
title: AddModRewriteInternalFunction
date: 2009-05-10 13:58:43 +0900
---


Apache モジュール界のスイスアーミーナイフこと mod_rewrite の中でも、最も何でもありな rewrite ができるのが、[RewriteMap](http://httpd.apache.org/docs/2.2/ja/mod/mod_rewrite.html#rewritemap) での prg タイプによる外部プログラム実行ですが、こいつは外部プログラムがひとつだけ常駐し、httpd と標準入出力を介してやりとりする、という形なので、並列処理させることができません。これは rewrite 処理するときにデータベースへ問い合わせるなど、I/O ブロッキングが発生するような処理をさせたいときには致命的なパフォーマンス劣化を引き起こすことになります。

これを解決するためには、Apache モジュールの中で望みの rewrite 処理をさせるようにすればいいのでは、と思い、RewriteMap にある int タイプに好きな internal function を追加できればいけるんじゃないないか、と考えたものの、[mod_rewrite のリファレンス](http://httpd.apache.org/docs/2.2/ja/mod/mod_rewrite.html) では、「you cannot create your own」とか書かれていて、追加できないっぽい。かと言って mod_rewrite.c に手を入れるのもやだなー、と思っていたところ、[mod_icpquery のドキュメント](http://code.google.com/p/modicpquery/wiki/Internals) を見つけた。これを見ると、好きな internal function を独立したモジュールの形で追加できそう、ってことでやってみたらできた。

以下が internal function を追加するためのモジュールテンプレ。rewrite_mapfunc_custom の中で、望みの処理を記述してあげるだけで OK。

	
	#!c
	#include "httpd.h"
	#include "http_config.h"
	#include "apr_optional.h"
	
	/* rewrite map function prototype from mod_rewrite.h */
	typedef char *(rewrite_mapfunc_t)(request_rec *r, char *key);
	
	/* optional function declaration from mod_rewrite.h */
	APR_DECLARE_OPTIONAL_FN(void, ap_register_rewrite_mapfunc,
	                        (char *name, rewrite_mapfunc_t *func));
	
	static char *rewrite_mapfunc_custom(request_rec *req, char *key)
	{
	    /* key を元にごにょごにょして value を生成 */
	    return value;
	}
	
	/* from mod_rewrite.c */
	static int pre_config(apr_pool_t *pconf,
	                      apr_pool_t *plog,
	                      apr_pool_t *ptemp)
	{
	    APR_OPTIONAL_FN_TYPE(ap_register_rewrite_mapfunc) *map_pfn_register;
	
	    /* register int: rewritemap handlers */
	    map_pfn_register = APR_RETRIEVE_OPTIONAL_FN(ap_register_rewrite_mapfunc);
	    if (map_pfn_register) {
	        map_pfn_register("custom", rewrite_mapfunc_custom);
	    }
	    return OK;
	}
	
	static void register_hooks(apr_pool_t *p)
	{
	    ap_hook_pre_config(pre_config, NULL, NULL, APR_HOOK_MIDDLE);
	}
	
	module AP_MODULE_DECLARE_DATA rewrite_mapfunc_custom_module = {
	    STANDARD20_MODULE_STUFF,
	    NULL,                  /* create per-dir    config structures */
	    NULL,                  /* merge  per-dir    config structures */
	    NULL,                  /* create per-server config structures */
	    NULL,                  /* merge  per-server config structures */
	    NULL,                  /* table of config file commands       */
	    register_hooks         /* register hooks                      */
	};
	

追加した internal function を呼び出すための httpd.conf は以下のような感じ。

	
	LoadModule rewrite_mapfunc_custom_module modules/mod_rewrite_mapfunc_custom.so
	
	RewriteEngine On
	ProxyPreserveHost On
	RewriteMap custom int:custom
	RewriteRule ^/(.*)$ http://${custom:%{HTTP_HOST}}/$1 [P,QSA]
	

この例では、Host ヘッダの内容を custom function に渡して、ホスト名を変換して proxy するけど、Host ヘッダはオリジナルのままで変換しない、といった処理を想定してます。

例の件はこんな感じで実現できそうだよ。＞[id:hiboma](http://d.hatena.ne.jp/hiboma/)

*2009/05/10 13:57:00 追記 *

github に Makefile 等も含めてコードアップしました。

http://github.com/mizzy/mod_rewrite_mapfunc_custom/tree/master
