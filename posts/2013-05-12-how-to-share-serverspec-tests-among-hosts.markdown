---
title: serverspec のテストをホスト間で共有する方法
date: 2013-05-12 03:06:48 +0900
---

今回は serverspec のテストをホスト間で共有する方法について説明します。

serverspec-init を実行して生成されるひな形ファイルは以下のようになっています。

```
|-- Rakefile
`-- spec
    |-- spec_helper.rb
    `-- www.example.jp
        `-- httpd_spec.rb
```

これを見てわかる通り、テスト対象となるホスト名でディレクトリが掘られ、その下に対象ホストに対する spec が置かれる、という形になっています。

したがって、複数の役割が同じホストに対してテストを実行しようとすると、こんな感じで同じ内容の spec ファイルが重複して置かれることになります。

```
|-- Rakefile
`-- spec
    |-- app001.example.jp
    |   `-- ruby_spec.rb
    |-- app002.example.jp
    |   `-- ruby_spec.rb
    |-- proxy001.example.jp
    |   `-- nginx_spec.rb
    |-- proxy002.example.jp
    |   `-- nginx_spec.rb
    `-- spec_helper.rb
```

実はこのようなファイル構成は、``serverspec-init`` で生成される ``Rakefile`` や ``spec_helper.rb`` に依存しているだけで、serverspec 本体の仕様には依存してません。したがって、``Rakefile`` や ``spec_helper.rb`` をカスタマイズすれば、好きなファイル構成にすることができます。

その一例として、spec をサーバのロール毎にわけ、各サーバに対して属するロールにひもづいたテスト実行する、というやり方について説明します。

まず、以下のようにロール毎にディレクトリを作成し、その下にロールにひもづいた spec ファイルを置きます。

```
|-- Rakefile
`-- spec
    |-- app
    |   `-- ruby_spec.rb
    |-- base
    |   `-- users_and_groups_spec.rb
    |-- db
    |   `-- mysql_spec.rb
    |-- proxy
    |   `-- nginx_spec.rb
    `-- spec_helper.rb
```

次に、以下のような ``Rakefile`` と ``spec/spec_helper.rb`` を置きます。

{% gist 5560916 %}

``rake -T`` を実行すると以下のように表示され、``rake serverspec`` ですべてのホストに対して実行したり、``rake serverspec:host`` で特定のホストに対して実行したりできることがわかります。

```
$ rake -T
rake serverspec           # Run serverspec to all hosts
rake serverspec:app001    # Run serverspec to app001.example.jp
rake serverspec:app002    # Run serverspec to app002.example.jp
rake serverspec:db001     # Run serverspec to db001.example.jp
rake serverspec:db002     # Run serverspec to db002.example.jp
rake serverspec:proxy001  # Run serverspec to proxy001.example.jp
rake serverspec:proxy002  # Run serverspec to proxy002.example.jp
```

``Rakefile`` 内で定義しているホストとロールのひもづけは、外部から JSON などで取得してきてもいいですし、工夫すれば、特定のロールに属するホスト群に対してのみ実行、といったこともできるでしょう。

こんな形で、どのホストに対してどのテストを実行するのか、というのは、serverspec 本体の仕様とは疎になってるので、``Rakefile`` と ``spec_helper.rb`` をカスタマイズすることで、各自の環境や目的にあったファイル構成にしたり、対象のホストに関する情報を外部から引っ張ってきたり、といったことも可能です。

