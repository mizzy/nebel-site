---
title: GitHub に coderwall バッヂの Organizations ができてる
date: 2013-01-30 01:04:31 +0900
---

[GitHub](http://github.com/) の [自分のプロフィールページ](https://github.com/mizzy) の Organizations のところに、[coderwall](http://coderwall.com/) のバッヂが表示されてることに少し前に気づいていて、これは各バッヂに対応した組織アカウントのメンバーに自分が入れらてるから、なわけですが、デフォルトでは Publicize されてないので、他の人からは見ることができません。Publicize してあげると、他の人からもこんな風に見えるようになります。

{% img /images/2013/01/coderwall-organizations.png %}

Publicize するには、各組織アカウントのページで「Members」タブを選択し、自分のアカウントの横の「Publicize membership」をクリックすれば良いです。

{% img /images/2013/01/publicize.png %}

上の画像は、Publicize した後のものです。

Publicize は手動でやるのはだるいので、スクリプトをつくってみました。

{% gist 4665462 %}

余談ですが、[octokit](https://github.com/pengwynn/octokit) で Publicize Membership するコードは、[自分がコントリビュートしたものです](https://github.com/pengwynn/octokit/pull/89) 。



