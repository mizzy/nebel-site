---
layout: post
title: HadoopAndScalaPackagesForCentOS
date: 2010-04-14 14:53:27 +0900
---
*2010/04/14 追記*

太田さんから twitter で[Hadoopは基本的にSun JDKのみでテストされているので、OpenJDKでの使用は危険らしいです。](http://twitter.com/kzk_mover/status/12147992526) とご指摘いただきました。ありがとうございます。

となると、Hadoop 以外にも Java 関連パッケージを利用したい場合には、Hadoop を OpenJDK 用にビルドするんじゃなくて、他の Java 関連パッケージを Sun JDK 用にビルドしなおすか、気持ち悪いけど併用するか、のどちらかになってしまうんですかね。

----
Hadoop を CentOS5 で利用する場合、[Cloudera’s Distribution for Hadoop (CDH)](http://www.cloudera.com/hadoop/) を [yum でインストール](http://archive.cloudera.com/docs/_yum.html) するのが簡単なんですが、http://java.sun.com/ から入手できる JDK パッケージに依存してるので、CentOS5で yum install できる OpenJDK パッケージ が使えません。

Hadoop 使うだけならそれでもいいんですが、他の yum で入る ant 等の Java 製ソフトウェアを利用しようと思うと、Sun から入手した JDK パッケージと yum で入る OpenJDK パッケージが同居して、気持ちが悪いです。

幸い、[CDH の SRPM](http://archive.cloudera.com/redhat/cdh/3/SRPMS/) も入手できるので、こいつを OpenJDK パッケージを利用する形でパッケージングしなおしました。

* http://svn.mizzy.org/public/yum/SRPMS/hadoop-0.20-0.20.2+228-1.centos.src.rpm

こいつをビルドするために ant 1.7 以降が必要なのだけど、CentOS で yum で入るのは 1.6 なので、ant 1.7 のパッケージもつくった。

* http://svn.mizzy.org/public/yum/SRPMS/ant-1.7.1-11.1.src.rpm

また、Hadoop + Scala を試してみたいので、Scala のパッケージと、Scala に必要な jline のパッケージもつくった。

* http://svn.mizzy.org/public/yum/SRPMS/scala-2.7.7-1.centos.src.rpm
* http://svn.mizzy.org/public/yum/SRPMS/jline-0.9.94-0.6.src.rpm
