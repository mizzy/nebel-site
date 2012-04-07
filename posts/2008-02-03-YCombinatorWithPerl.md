---
layout: post
title: YCombinatorWithPerl
date: 2008-02-03 03:03:52 +0900
---


計算機科学を学んでいる人にとっては今更な話題らしいですが、経済学部出身の自分には目新しい話題なので書いてみます。（といっても、全然知らなかった、というわけでもないんですが。）

[id:amachang](http://d.hatena.ne.jp/amachang/20080124/1201199469) さんのエントリにある最終形のみを Perl で書くとこんな感じかな。

	
	#!perl
	my $Y = sub {
	    my $f = shift;
	    return sub {
	        my $g = shift;
	        return sub {
	            my $m = shift;
	            return $f->($g->($g))->($m);
	        }
	    }->(
	        sub {
	            my $g = shift;
	            return sub {
	                my $m = shift;
	                return $f->($g->($g))->($m);
	            };
	        }
	    )
	};
	
	my $fib = sub {
	    my $f = shift;
	    return sub {
	        my $n = shift;
	        return $n <= 2 ? 1 : $f->($n - 1) + $f->($n - 2);
	    };
	};
	
	warn $Y->($fib)->(10);
	

----

なぜこれで再帰として動作するかを考えるにあたって、[id:gotin](http://d.hatena.ne.jp/gotin/20080127/1201372491) さんのエントリと同内容のことを、Perl で考えてみる。

簡単にするために最終形の Y コンビネータになる前の中間形のコードで考える。

	
	#!perl
	my $Y = sub {
	    my $f = shift;
	    my $g;
	    return $g = sub {
	        my $n = shift;
	        $f->($g)->($n);
	    }
	};
	
	my $fib = sub {
	    my $f = shift;
	    return sub {
	        my $n = shift;
	        return $n <= 2 ? 1 : $f->($n - 1) + $f->($n - 2);
	    }
	};
	
	warn $Y->($fib)->(5);
	

$Y->($fib) は、 my $Y = sub { ... } において、$f に $fib が代入され、結果として以下の関数が返ることになる。

	
	#!perl
	sub {
	    my $n = shift;
	    $fib->($g)->($n);
	}
	

そうなると $Y->($fib)->(5) は、以下のように変換できる。

	
	#!perl
	$fib->($g)->(5)
	

$fib->($g) は、my $fib = sub { ... } の $f に $g が代入されるので、$fib->($g)->(5) は、

	
	#!perl
	sub {
	   my $n = shift;
	   return $n <= 2 ? 1 : $g->($n - 1) + $g->($n - 2);
	}->(5);
	

ということになる。

なのでこの $n に 5 が代入され、結果として $fib->($g)->(5) は以下のように変換される。

	
	#!perl
	  $g->(4) ... [A]
	+ $g->(3) ... [B]
	

[A] を更に変換してみると、$g->(4) は $fib->($g)->(4) となり、

	
	#!perl
	sub {
	   my $n = shift;
	   return $n <= 2 ? 1 : $g->($n - 1) + $g->($n - 2);
	}->(4);
	

を実行するのと同じ。というわけで、$g->(4) は、

	
	#!perl
	$g->(3) + $g->(2) ... [A]
	

になる。同様に [B] を変換すると、

	
	#!perl
	$g->(2) + $g->(1) ... [B]
	

となる。今までのところまでをまとめると、$Y->($fib)->(5) は以下のように変換される。

	
	#!perl
	  $g->(3) + $g->(2) ... [A]
	+ $g->(2) + $g->(1) ... [B]
	

で、$g->(3) は [B] の変換と同様なので、更に以下のように変換される。

	
	#!perl
	  $g->(2) + $g->(1) + $g->(2) ... [A]
	+ $g->(2) + $g->(1)           ... [B]
	

ここで $g->(2) は、

	
	#!perl
	sub {
	   my $n = shift;
	   return $n <= 2 ? 1 : $g->($n - 1) + $g->($n - 2);
	}->(2);
	

であり、$n <= 2 であれば 1 が返る。ということは、$g->(2) も $g->(1) も 1 だから、[A] + [B] は以下のように変換される。

	
	#!perl
	  1 + 1 + 1 ... [A]
	+ 1 + 1     ... [B]
	

というわけで、結果は 5 になる。ということらしい。なんとなくわかった。
