---
layout: post
title: JSONParserWithParseYapp
date: 2011-02-17 00:28:16 +0900
---
構文解析をちゃんと学ばないとなー、と前々から思いつつしばらく放置だったけど、なんとなくやる気になったのでやってみる。

[ZIGOROu](http://twitter.com/zigorou) さんの [Parse::Yapp ヨチヨチ歩き](http://d.hatena.ne.jp/ZIGOROu/20080422/1208849930) で [Parse::Yapp](http://search.cpan.org/~fdesar/Parse-Yapp/lib/Parse/Yapp.pm) の使い方を学びつつ、[Rubyソースコード完全解説 第9章 速習yacc](http://www.loveruby.net/ja/rhg/book/yacc.html) でパーサの書き方の基礎がなんとなくわかった気になり、でも実際は自分で書いてみなきゃわからん、ってことで、[hakobe](http://twitter.com/hakobe) さんの [Parse::RecDescentでJSONをパース](http://d.hatena.ne.jp/hakobe932/20090130/1233327296) を参考に、Parse::Yapp で JSON パーサを書いてみることにした。

パーサ＋スキャナは以下のような感じ。

	
	#!perl
	%{
	use strict;
	use warnings;
	%}
	%%
	JSON       : value
	           ;
	value      : atom
	           | number
	           | string
	           | '[' array             { return $_[2] }
	           | '{' object            { return $_[2] }
	           ;
	array      : ']'                   { return [] }
	           | ',' ']'               { return [] }
	           | element array_cdr     { unshift @{$_[2]}, $_[1];return $_[2] }
	           ;
	array_cdr  : ']'                   { return [] }
	           | ',' ']'               { return [] }
	           | ',' element array_cdr { unshift @{$_[3]}, $_[2];return $_[3] }
	           ;
	element    : value
	           ;
	object     : '}'                   { return {} }
	           | ',' '}'               { return {} }
	           | member object_cdr     { return { %{ $_[2] }, %{ $_[1] } } }
	           ;
	object_cdr : '}'                   { return {} }
	           | ',' '}'               { return {} }
	           | ',' member object_cdr { return { %{ $_[3] }, %{ $_[2] } } }
	           ;
	member     : key ':' value         { return { $_[1] => $_[3] } }
	           ;
	key        : string
	           | identifier
	           ;
	%%
	sub yyerror {}
	
	sub yylex {
	    my ( $self ) = @_;
	    my $number = qr/-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]\d+)?/;
	    my $double_quoted_string = qr/
	            ^"([^\x00-\x1f\"\\]*
	            (?:\\(?:[\"\\\/bfnrt]|u[0-9a-fA-F]{4})
	            [^\x00-\x1f\"\\]*)*)"
	        /xms;
	    my $single_quoted_string = qr/
	            ^'([^\x00-\x1f\'\\]*
	            (?:\\(?:[\'\\\/bfnrt]|u[0-9a-fA-F]{4})
	            [^\x00-\x1f\'\\]*)*)'
	        /xms;
	
	    for ( $self->YYData->{INPUT} ) {
	        s|\s+||;
	        s|^($number)||                and return ('number', $1);
	        s/^(true|false|null)//        and return ('atom', $1);
	        s|^([_a-zA-Z][_a-zA-Z0-9]*)|| and return ('identifier', $1);
	        s|$double_quoted_string||     and return ('string', $1);
	        s|$single_quoted_string||     and return ('string', $1);
	        s|^(.)||                      and return ($1, $1);
	    }
	    return ('', undef);
	}
	
	sub run {
	    my $self = shift;
	    return $self->YYParse( yylex => \&yylex, yyerror => \&yyerror );
	}
	

こいつを yapp コマンドにかけるとパーサモジュールができる。

	
	#!sh
	$ yapp -m JSONParser json.yp
	

このモジュールを使ってパースしてみる。

	
	#!perl
	#!/usr/bin/perl
	
	use strict;
	use warnings;
	use Test::More qw(no_plan);
	use JSONParser;
	
	my $parser = JSONParser->new;
	$parser->YYData->{INPUT} = q{[
	        'Mercury',
	        "Venus",
	        ["Earth", ['Moon']],
	        ['Mars', ["Phobos", 'Deimos']],
	        ['Jupiter',["Io", 'Europa', "Ganymede", 'Callisto']]
	]};
	my $result = $parser->run;
	
	is_deeply($result, ['Mercury', "Venus", ["Earth", ['Moon']], ['Mars', ["Phobos", 'Deimos']], ['Jupiter',["Io", 'Europa', "Ganymede", 'Callisto']]]);
	

うん、なんとなくわかってきた気がする。

[Rubyソースコード完全解説 第9章 速習yacc](http://www.loveruby.net/ja/rhg/book/yacc.html) の中で「客観的に見てもこの分野に関しては一番わかりやすい本」とオススメされていた[Rubyを256倍使うための本 無道編](http://www.amazon.co.jp/dp/4756137091) も買ってみた。