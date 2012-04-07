---
layout: post
title: DotCloudCliBehaviorOverView
date: 2011-07-10 20:20:07 +0900
---


Now I'm investigating the behavior of [dotcloud.cli](http://pypi.python.org/pypi/dotcloud.cli).I will write down the things I found.

With --export option, you can see the raw response of dotcloud API.

For example, if you execute dotcloud command for the first time with --export option, you will see the result like this.

	
	$ dotcloud --export
	Warning: /Users/miya/.dotcloud/dotcloud.conf does not exist.
	Enter your api key (You can find it at http://www.dotcloud.com/account/settings): XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	{
	    "data": [
	        [
	            "key", 
	            "-----BEGIN DSA PRIVATE KEY-----\nXXXXXXXXXX...\n-----END DSA PRIVATE KEY-----\n"
	        ]
	    ], 
	    "type": "cmd"
	}
	

If '"type": "cmd"' is given, dotcloud command call the appropriate method.In this case, key() method of Remote class in dotcloud/cli/remote.py will be called and SSH key string will be written to ~/.dotcloud/dotcloud.key.

Which method is called are defined in dotcloud/cli/cli.py like this.

	
	#!python
	def run_remote(cmd):
	    r = remote.Remote()
	    handlers = {
	            'set_url': r.set_url,
	            'run': r.run,
	            'script': r.run_script,
	            'sftp': r.sftp,
	            'pull': r.pull,
	            'push': r.push,
	            'rsync': r.rsync,
	            'git': r.git,
	            'hg': r.hg,
	            'upload': r.upload,
	            'loop': lambda *x: run_loop(*x),
	            'confirm': local.confirm,
	            'call': lambda x: run_command(x, True),
	            'echo': lambda x: sys.stdout.write('{0}\n'.format(x)),
	            'echo_error': lambda x: sys.stderr.write('{0}\n'.format(x)),
	            'set_verbose': r.set_verbose,
	            'key': r.key
	            }
	

Let's see another command option.

	
	$ dotcloud --export create helloworldapp
	{
	    "data": "Created repos \"helloworldapp\"", 
	    "type": "success"
	}
	

In this case, type is not cmd, so dotcloud command will do nothing anymore.

In the case of option push, API response is like this.

	
	$ dotcloud --export push helloworldapp
	{
	    "data": [
	        [
	            "upload", 
	            ".", 
	            "ssh://dotcloud@uploader.dotcloud.com:21122/helloworldapp", 
	            {
	                "rsync": {
	                    "excludes": [
	                        "*.pyc", 
	                        ".git", 
	                        ".hg"
	                    ]
	                }, 
	                "check": true
	            }
	        ], 
	        [
	            "call", 
	            "deploy helloworldapp.default"
	        ]
	    ], 
	    "type": "cmd"
	}
	

"type" is "cmd", so Remote.upload() will be called and run_command('deploy helloworldapp.default', True) will be called.
