---
layout: post
title: library/perl/trunk/Net-Amazon-ECS/lib/Net/Amazon/ECS.pm
date: 2009-07-21 00:58:15 +0900
---
source:library/perl/trunk/Net-Amazon-ECS/lib/Net/Amazon/ECS.pm


# NAME

Net::Amazon::ECS - [One line description of module's purpose here]


# VERSION

This document describes Net::Amazon::ECS version 0.0.1


# SYNOPSIS


	
	    use Net::Amazon::ECS;
	
	    my $ua =  Net::Amazon::ECS->new(
	        access_key_id => 'YOUR_AWS_ACCESS_KEY_ID',
	        associate_tag => 'YOUR_AFFILIATE_ID',
	        locale        => 'jp',
	    );
	
	    my $req = Net::Amazon::Request::Keyword->new(
	        keywords     => 'SEARCH KEYWORDS',
	        search_index => 'books',
	        sort         => 'daterank',
	    );
	
	    my $res = $ua->request($req);
	
	    croak $res->message if $res->is_error;
	
	    my @items = $res->items;
	

# DESCRIPTION


# INTERFACE


# DIAGNOSTICS

 `Error message here, perhaps with %s placeholders`:: [Description of error here]
 `Another error message here`:: [Description of error here]
[Et cetera, et cetera]


# CONFIGURATION AND ENVIRONMENT

Net::Amazon::ECS requires no configuration files or environment variables.


# DEPENDENCIES

None.


# INCOMPATIBILITIES

None reported.


# BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to `bug-net-amazon-ecs@rt.cpan.org`, or through the web interface at http://rt.cpan.org.


# AUTHOR

Gosuke Miyashita `<gosukenator@gmail.com>`


# LICENCE AND COPYRIGHT

Copyright (c) 2006, Gosuke Miyashita `<gosukenator@gmail.com>`. All rights reserved.

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See perlartistic.


# DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

