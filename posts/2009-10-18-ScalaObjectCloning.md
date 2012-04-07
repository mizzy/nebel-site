---
layout: post
title: ScalaObjectCloning
date: 2009-10-18 11:51:50 +0900
---


[Java言語で学ぶデザインパターン入門](http://www.amazon.co.jp/dp/4797327030/) の第6章 Prototype を [Scala で書き直してみて](http://github.com/mizzy/scala-design-patterns/tree/master/Prototype/)、オブジェクトのクローニングでちょっとつまづいたのでメモ。

結論を先に言うと、オブジェクトのクローニングしたい場合には、クラスやトレイトの宣言時に、@cloneable アノテーションを入れると OK。

	
	@cloneable class Hoge {
	  ...
	}
	

以下、つまづいて調べた経緯。元書籍での Product クラスは以下のように、Cloneable を継承している。

	
	#!java
	package framework;
	
	public interface Product extends Cloneable {
	    public abstract void use(String s);
	    public abstract Product createClone(); 
	}
	

で、Scala でのクローニングについて、「Scala cloneable」でググると、一番上に出てきた http://www.scala-lang.org/node/110 では、以下のようなコードが載っていた。

	
	trait Cloneable extends java.lang.Cloneable {
	  override def clone(): Cloneable = { super.clone(); this }
	}
	trait Resetable {
	  def reset: Unit
	}
	

これを参考にして、Product クラスを Scala で以下のように書き直してみた。

	
	package framework
	 
	trait Product extends java.lang.Cloneable {
	  def use(s: String): Unit
	  def createClone(): Product
	  override def clone(): Cloneable = { super.clone(); this }
	}
	

これでとりあえずは動いたんだけど、いまいちスッキリしない。そもそも Scala は Java だけではなく、.NET でも動くということなんだけど、java.lang.Cloneable を継承してると、Java でしか動かなくてイマイチ。（まあ、習作用コードでそこまで気にする必要もないんだけど。）

というわけで調べてみたら、@cloneable アノテーションを使えばいいみたい。

	
	package framework
	 
	@cloneable trait Product {
	  def use(s: String): Unit
	  def createClone(): Product
	}
	

これで意図通りに動いた。

@cloneable を頭に入れないと、実行時に CloneNotSupportedException が発生する。
