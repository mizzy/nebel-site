---
title: アレクサ スマホを探してでスマホを鳴らすやつ
date: 2017-12-14 14:16:35 +0900
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/ejXWG8fOyjA" frameborder="0" gesture="media" allow="encrypted-media" allowfullscreen></iframe>

[Lambda Function のソースコードはこちら](https://github.com/mizzy/alexa-findmyphone)。

----

## これは何？

「アレクサ、スマホを探すを開いて」  
「誰のスマホを探しますか」  
「長男」  
「長男のスマホを鳴らしています」  

といった感じで、アレクサからスマホに電話をかけてもらい、スマホを探すやつ。

----

## つくった動機

家の中で iPhone を見失った場合、パソコンや妻の iPhone から「iPhoneを探す」にアクセスして音を鳴らしていたけど、パソコンを開いてブラウザからアクセスしたり、妻の iPhone を借りたり、といった手間がかかっていたので、声だけで実現できるようにしたかった。

ifttt でも同様のことができるけど、US Only だったり、既存のアレクサスキルだと、アプリを入れる必要があったり、複数の端末に対応してるのかわからなかったりしたので、自分でつくることにした。

基本的なつくりは [アレクサごはんだよで LINE 通知するやつ](http://mizzy.org/blog/2017/12/12/1/) と同じで、LINE API 叩くところが Twilio API 叩くだけ、といった感じなので、さくっとつくれた。

----

## 使い方

[GitHub 上の README](https://github.com/mizzy/alexa-findmyphone#使い方) を参照。
