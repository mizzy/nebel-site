---
title: specinfra をベースとしたオレオレ Configuration Management Tool/オレオレ serverspec 構想
date: 2013-12-04 00:32:14 +0900
---

[specinfra](https://github.com/serverspec/specinfra) v0.0.6 では、[serverspec](https://github.com/serverspec/serverspec)/[configspec](https://github.com/serverspec/configspec)/[Syllabus](https://github.com/serverspec/syllabus) で実行する具体的なコマンドを SpecInfra::Command::* に統合しました。

以前のバージョンまでは「OS を自動判別し、OS に適したコマンドクラスを返す commands と呼んでいるレイヤー」を specinfra で提供していましたが、コマンドクラスは各プロダクト側で実装していました。

specinfra v0.0.6 では、コマンドクラスも specinfra 側で持つようになりました。

これで何がうれしいのかというと、オレオレ Configuration Management Tool が簡単に実装できるようになる、ということです。

Exec/SSH といったバックエンドの実行形式/出力形式の切り替えや、OSを自動判別して適切なコマンドを実行する部分はすべて specinfra 側に任せられるので、CMT を新たに実装する人は、DSL 的な部分と、その DSL から呼び出すメソッドを定義するだけで良い、ということになります。（とはいえ、CMT で使えるコマンドは specinfra 側で出そろってないので、まだまだこれからではありますが。）

configspec では RSpec ベースな DSL、Syllabus では手続き的な DSL を採用していますが、これらが好みではない人は、自分の好きな DSL を持った CMT を容易に実装することができるようになります。

また、serverspec のコマンドも specinfra に統合されたので、オレオレ serverspec の実装も簡単にできるようになります。例えば、RSpec は好みじゃないから minitest ベースの serverspec を実装する、みたいなことが容易にできるはずです。

というわけで、みんなでオレオレ Configuration Management Tool/オレオレ serverspec をつくってみましょう。

（コマンドを specinfra に統合する、というアイデアは、あんちぽさんから頂きました。いつもありがとうございます。）
