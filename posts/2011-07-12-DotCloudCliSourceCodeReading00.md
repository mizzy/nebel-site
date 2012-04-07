---
layout: post
title: DotCloudCliSourceCodeReading00
date: 2011-07-12 01:43:32 +0900
---


I wonder how "dotcloud push" acts, especially on uploading files, so I read the [dotcloud.cli source code](http://pypi.python.org/pypi/dotcloud.cli).

If you execute "dotcloud push" with --export option, you'll get the response like this.

	
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
	

So you know that dotcloud command will run Remote.upload() method.(See DotCloudCliBehaviorOverView.)

You can see the upload() method in dotcloud/cli/remote.py.

	
	#!python
	    def upload(self, local_dir, destination, args):
	        if args.get('check'):
	            local_dir = self.check_pushdir(local_dir)
	        self.info('# upload {0} {1}'.format(local_dir, destination))
	        if os.path.isdir(os.path.join(local_dir, '.hg')):
	            return self.hg(local_dir, destination, args.get('hg', {}))
	        if os.path.isdir(os.path.join(local_dir, '.git')):
	            return self.git(local_dir, destination, args.get('git', {}))
	        return self.rsync(local_dir, destination, args.get('rsync', {}))
	

If you have .hg directory, dotcloud command runs self.hg().If you have .git directory, dotcloud command runs self.git().Otherwise dotcloud command runs self.rsync().

You can see these methods in the same file.

	
	#!python
	    def rsync(self, local_dir, destination, args):
	        self.info('# rsync')
	        excludes = args.get('excludes')
	        url = utils.parse_url(destination)
	        ssh = ' '.join(self._ssh_options)
	        ssh += ' -p {0}'.format(url['port'])
	        if not os.path.isfile(local_dir) and not local_dir.endswith('/'):
	            local_dir += '/'
	        rsync = (
	                    'rsync', '-lpthrvz', '--delete', '--safe-links',
	                ) + tuple('--exclude={0}'.format(e) for e in excludes) + (
	                    '-e', ssh, local_dir,
	                    '{user}@{host}:{dest}/'.format(user=url['user'],
	                        host=url['host'], dest=url['path'])
	                )
	        try:
	            ret = subprocess.call(rsync, close_fds=True)
	            if ret != 0:
	                self.warning_ssh()
	            return ret
	        except OSError:
	            self.die('rsync')
	
	    def hg(self, local_dir, destination, args):
	        self.info('# hg')
	        with utils.cd(local_dir):
	            try:
	                ssh = ' '.join(self._ssh_options)
	                args = ('hg', 'push', '--ssh', ssh, '-f', destination)
	                ret = subprocess.call(args, close_fds=True)
	                if ret != 0:
	                    self.warning_ssh()
	                return ret
	            except OSError:
	                self.die('hg')
	
	    def git(self, local_dir, destination, args):
	        self.info('# git')
	        with utils.cd(local_dir):
	            try:
	                os.environ['GIT_SSH'] = '__dotcloud_git_ssh'
	                os.environ['DOTCLOUD_SSH_KEY'] = config.CONFIG_KEY
	                ret = subprocess.call(('git', 'push', '-f', '--all',
	                    destination), close_fds=True)
	                if ret != 0:
	                    self.warning_ssh()
	                return ret
	            except OSError:
	                self.die('git')
	