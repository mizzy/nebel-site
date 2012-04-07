---
layout: post
title: library/perl/trunk/Parse-Apache-ServerStatus-Extended/lib/Parse/Apache/ServerStatus/Extended.pm
date: 2007-07-09 21:03:59 +0900
---
source:library/perl/trunk/Parse-Apache-ServerStatus-Extended/lib/Parse/Apache/ServerStatus/Extended.pm


# NAME

Parse::Apache::ServerStatus::Extended - Simple module to parse apache's extended server-status.


# SYNOPSIS


	
	    use Parse::Apache::ServerStatus::Extended;
	
	    my $parser = Parse::Apache::ServerStatus::Extended->new;
	
	    $parser->request(
	       url     => 'http://localhost/server-status',
	       timeout => 30
	    ) or die $parser->errstr;
	
	    my $stat = $parser->parse or die $parser->errstr;
	
	    # or both in one step
	
	    my $stats = $parser->get(
	       url     => 'http://localhost/server-status',
	       timeout => 30
	    ) or die $parser->errstr;
	

# DESCRIPTION

This module parses the content of apache's extended server-status.It works nicely with apache versions 1.3 and 2.x.


# METHODS


## new()

Call `new()` to create a new Parse::Apache::ServerStatus::Extended object.


## request()

This method accepts one or two arguments: `url` and `timeout`. It requests the url and safes the content into the object. The option `timeout` is set to 180 seconds if it is not set.


## parse()

Call `parse()` to parse the extended server status. This method returns an array reference with the parsed content.

It's possible to call `parse()` with the content as an argument.


	
	    my $stat = $prs->parse($content);
	
If no argument is passed then `parse()` looks into the object for the content that is stored by `request()`.


## get()

Call `get()` to `request()` and `parse()` in one step. It accepts the same options like `request()` and returns the array reference that is returned by `parse()`.


# SEE ALSO

Parse::Apache::ServerStatus


# AUTHOR

Gosuke Miyashita `<gosukenator at gmail.com>`


# LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See perlartistic.


# DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

