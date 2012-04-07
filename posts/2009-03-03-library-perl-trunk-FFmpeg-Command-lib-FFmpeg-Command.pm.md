---
layout: post
title: library/perl/trunk/FFmpeg-Command/lib/FFmpeg/Command.pm
date: 2009-03-03 22:58:20 +0900
---
source:library/perl/trunk/FFmpeg-Command/lib/FFmpeg/Command.pm


# NAME

FFmpeg::Command - A wrapper class for ffmpeg command line utility.


# DESCRIPTION

A simple interface for using ffmpeg command line utility.


# SYNOPSIS


	
	    use FFmpeg::Command;
	
	    my $ffmpeg = FFmpeg::Command->new('/usr/local/bin/ffmpeg');
	
	    $ffmpeg->input_options({
	        file => $input_file,
	    });
	
	    # Set timeout
	    $ffmpeg->timeout(300);
	
	    # Convert a video file into iPod playable format.
	    $ffmpeg->output_options({
	        file   => $output_file,
	        device => 'ipod',
	    });
	
	    my $result = $ffmpeg->exec();
	
	    croak $ffmpeg->errstr unless $result;
	
	    # This is same as above.
	    $ffmpeg->output_options({
	        file                => $output_file,
	        format              => 'mp4',
	        video_codec         => 'mpeg4',
	        bitrate             => 600,
	        frame_size          => '320x240',
	        audio_codec         => 'libaac',
	        audio_sampling_rate => 48000,
	        audio_bit_rate      => 64,
	    });
	
	    $ffmpeg->exec();
	
	
	    # Convert a video file into PSP playable format.
	    $ffmpeg->output_options({
	        file  => $output_file,
	        device => 'psp',
	    });
	
	    $ffmpeg->exec();
	
	    # This is same as above.
	    $ffmpeg->output_options({
	        file                => $output_file,
	        format              => 'psp',
	        video_codec         => 'mpeg4',
	        bitrate             => 600,
	        frame_size          => '320x240',
	        audio_codec         => 'libaac',
	        audio_sampling_rate => 48000,
	        audio_bit_rate      => 64,
	    });
	
	    $ffmpeg->exec();
	
	    # Execute ffmpeg with any options you like.
	    # This sample code takes a screnn shot.
	    $ffmpeg->input_file($input_file);
	    $ffmpeg->output_file($output_file);
	
	    $ffmpeg->options(
	        '-y',
	        '-f'       => 'image2',
	        '-pix_fmt' => 'jpg',
	        '-vframes' => 1,
	        '-ss'      => 30,
	        '-s'       => '320x240',
	        '-an',
	    );
	
	    $ffmpeg->exec();
	

# METHODS


## new('/usr/bin/ffmpeg')

Contructs FFmpeg::Command object.It takes a path of ffmpeg command. You can omit this argument and this module searches ffmpeg command within PATH environment variable.


## timeout()

Set command timeout.Default is 0.


## input_options({ %options })

Specify input file name and input options.(Now no options are available.)

 file:: a file name of input file.


## output_options({ %options })

Specify output file name and output options.

Avaiable options are:

 file:: a file name of output file.
 format:: Output video format.
 video_codec:: Output video codec.
 bitrate:: Output video bitrate.
 frame_size:: Output video screen size.
 audio_codec:: Output audio code.
 audio_sampling_rate:: Output audio sampling rate.
 audio_bit_rate:: Output audio bit rate.
 title:: Set the title.
 author:: Set the author.
 comment:: Set the comment.


## input_file('/path/to/inpuf_file')

Specify input file name using with options() method.


## output_file('/path/to/output_file')

Specify output file name using with options() method.


## options( @options )

Specify ffmpeg command options directly.


## execute()

Executes ffmpeg comman with specified options.


## exec()

An alias of execute()


## stdout()

Get ffmpeg command output to stdout.


## stderr()

Get ffmpeg command output to stderr.


# AUTHOR

Gosuke Miyashita, `<gosukenator at gmail.com>`


# BUGS

Please report any bugs or feature requests to `bug-ffmpeg-command at rt.cpan.org`, or through the web interface at http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FFmpeg-Command. I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


# SUPPORT

You can find documentation for this module with the perldoc command.


	
	    perldoc FFmpeg::Command
	
You can also look for information at:

* AnnoCPAN: Annotated CPAN documentation

 http://annocpan.org/dist/FFmpeg-Command

* CPAN Ratings

 http://cpanratings.perl.org/d/FFmpeg-Command

* RT: CPAN's request tracker

 http://rt.cpan.org/NoAuth/Bugs.html?Dist=FFmpeg-Command

* Search CPAN

 http://search.cpan.org/dist/FFmpeg-Command



# ACKNOWLEDGEMENTS


# COPYRIGHT & LICENSE

Copyright 2006 Gosuke Miyashita, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

