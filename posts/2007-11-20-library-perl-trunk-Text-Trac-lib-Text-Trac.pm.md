---
layout: post
title: library/perl/trunk/Text-Trac/lib/Text/Trac.pm
date: 2007-11-20 23:20:38 +0900
---
source:library/perl/trunk/Text-Trac/lib/Text/Trac.pm


# NAME

Text::Trac - Perl extension for formatting text with Trac Wiki Style.


# VERSION

Version 0.08


# SYNOPSIS


	
	    use Text::Trac;
	
	    my $parser = Text::Trac->new(
	        trac_url      => 'http://trac.mizzy.org/public/',
	        disable_links => [ qw( changeset ticket ) ],
	    );
	
	    $parser->parse($text);
	
	    print $parser->html;
	

# DESCRIPTION

Text::Trac parses text with Trac WikiFormatting and convert it to html format.


# METHODS


## new

Constructs Text::Trac object.

Available arguments are:


### trac_url

Base URL for TracLinks.Default is /. You can specify each type of URL individually. Available URLs are:

 trac_attachment_url::  trac_changeset_url::  trac_log_url::  trac_milestone_url::  trac_report_url::  trac_source_url::  trac_ticket_url::  trac_wiki_url:: 

### disable_links

Specify TracLink types you want to disable. All types are enabled if you don't specify this option.


	
	    my $parser = Text::Trac->new(
	        disable_links => [ qw( changeset ticket ) ],
	    );
	

### enable_links

Specify TracLink types you want to enable.Other types are disabled. You cannot use both disable_links and enable_links at once.


	
	    my $parser = Text::Trac->new(
	        enable_links => [ qw( changeset ticket ) ],
	    );
	

## parse

Parses text and converts it to html format.


## process

An alias of parse method.


## html

Return converted html string.


# SEE ALSO

 Text::Hatena::  Trac http://www.edgewall.com/trac/::  Trac WikiFormatting http://projects.edgewall.com/trac/wiki/WikiFormatting:: 

# AUTHORS

Gosuke Miyashita, `<gosukenator at gmail.com>`

Hideaki Tanaka, `<drawn.boy at gmail.com)>`


# BUGS

Please report any bugs or feature requests to `bug-text-trac at rt.cpan.org`, or through the web interface at http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Trac. I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


# SUPPORT

You can find documentation for this module with the perldoc command.


	
	    perldoc Text::Trac
	
You can also look for information at:

* AnnoCPAN: Annotated CPAN documentation

 http://annocpan.org/dist/Text-Trac

* CPAN Ratings

 http://cpanratings.perl.org/d/Text-Trac

* RT: CPAN's request tracker

 http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Trac

* Search CPAN

 http://search.cpan.org/dist/Text-Trac



# COPYRIGHT & LICENSE

Copyright 2006 Gosuke Miyashita, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

