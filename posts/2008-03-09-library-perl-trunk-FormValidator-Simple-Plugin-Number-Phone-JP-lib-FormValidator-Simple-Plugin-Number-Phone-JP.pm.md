---
layout: post
title: library/perl/trunk/FormValidator-Simple-Plugin-Number-Phone-JP/lib/FormValidator/Simple/Plugin/Number/Phone/JP.pm
date: 2008-03-09 12:51:35 +0900
---
source:library/perl/trunk/FormValidator-Simple-Plugin-Number-Phone-JP/lib/FormValidator/Simple/Plugin/Number/Phone/JP.pm


# NAME

FormValidator::Simple::Plugin::Number::Phone::JP - Japanese phone number validation


# SYNOPSIS


	
	  use FormValidator::Simple qw/Number::Phone::JP/;
	
	  my $result > [
	      tel       => [ 'NOT_BLANK', 'NUMBER_PHONE_JP' ],
	  ] );
	

# DESCRIPTION

This modules adds Japanese phone number validation command to FormValidator::Simple.


# SEE ALSO

FormValidator::Simple

Number::Phone::JP


# AUTHOR

Gosuke Miyashita, <gosukenator@gmail.com>


# COPYRIGHT AND LICENSE

Copyright (C) 2005 by Gosuke Miyashita

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself, either Perl version 5.8.5 or, at your option, any later version of Perl 5 you may have available.

