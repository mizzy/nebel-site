---
layout: post
title: TeXPageFilledWithImage
date: 2011-02-23 23:45:53 +0900
---


TeX で表紙画像的なものが作りたくて色々調べてたら、[Google グループで見つけた](https://groups.google.com/group/fj.comp.texhax/browse_thread/thread/0be2662c944adf8f/6a4fdf56cfaeecaa?hl=ja&pli=1) のでメモ。


	
	#!tex
	\documentclass[a4paper]{jsbook}
	\usepackage[dvipdfmx,hiresbb]{graphicx}
	\begin{document}
	
	\enlargethispage{\paperwidth}
	\thispagestyle{empty}
	\vspace*{-1truein}
	\vspace*{-\topmargin}
	\vspace*{-\headheight}
	\vspace*{-\headsep}
	\vspace*{-\topskip}
	\noindent\hspace*{-1in}\hspace*{-\oddsidemargin}
	\includegraphics[width=\paperwidth,height=\paperheight]{cover_image.png}
	
	\end{document}
	

いくつか注意が必要で、

	
	#!tex
	\enlargethispage{\paperwidth}
	

は、これがないと、1ページ目を画像いっぱいのページにしようと思っても空白ページになってしまい、画像いっぱいのページは2ページ目になってしまう。また、

	
	#!tex
	\noindent\hspace*{-1in}\hspace*{-\oddsidemargin}
	

は奇数ページの場合なので、偶数ページの場合は、

	
	#!tex
	\noindent\hspace*{-1in}\hspace*{-\evensidemargin}
	

とする。