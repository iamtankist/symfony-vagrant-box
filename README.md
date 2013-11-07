# Project "Vagrapussy (Hulk Edition)"

## Overview

This project is intended to provide a simple and a fast way to set up VM with installed and pre-configured Symonfy Standard Edition in it. This is helpful to quickly try out something, as well as to bootstrap a new development project. It also sets up some additional complimenting maintenance scripts around Symfony project, to ease some routine operations.

## Prerequisites

I have provided software versions installed on my machine, please confirm if this works on earlier versions for you.

 - VirtualBox 4.2.16 
 - Vagrant 1.2.4
 - Puppet 2.7.11
 - Git 1.7.9.5

## Setup

You need to clone the repo from the BitBucket 

	git clone git@bitbucket.org:sensiolabs/slde-rnd-devbox-hulk.git testbox

or if you got this as an archive

	git init

This will create a testbox folder for you, with all the necessary configuration in it. Next 

	git submodule init
	git submodule update

You might want to take a look at box.json in the newly created folder, though it's not necessary, it will work with default values as well. 

	{
	    "name"         : "example-box",
	    "host_ip"      : "192.168.66.1",
	    "guest_ip"     : "192.168.66.65",
	    "project_name" : "example",
	    "project_root" : "/var/www",
	    "hostname"     : "example.local",
	    "mysql_root"   : "root"
	}


Note: later on in this manual I use 192.168.66.65 and example.local as reference. If you customize them, use customized values accordingly.

Customize values as needed and run 

	vagrant up

This will do the following for you

 - create a virtual box with name example-box
 - assign it the guest_ip
 - will install nginx, php, php-fpm, mysql, git, ant, composer
 - using composer will checkout the Symfony version for you 
 - will whitelist the host_ip for the 


## Result

Navigate your browser to [http://192.168.66.65](http://192.168.66.65)

## Adding Host entry (optional)

I wish I could say 

	sudo echo "192.168.66.65	example.local" >> /etc/hosts

but as a humble user of Windows we will follow the standard procedure. So

	- Open your Notepad with Administrator rights
	- Open the "C:\Windows\System32\drivers\etc\hosts" file in it
	- Append "192.168.66.65 example.local" to the file

now it should be available under [http://example.local/app_dev.php](http://example.local/app_dev.php)

## Accessing box

Either 
	
	vagrant ssh

or use your favourite terminal to access ssh://vagrant@192.168.66.65 (password would be vagrant too, though i would strongly recommend to set up SSH key authentication for your own comfort)

## Workflow

There is a reason why project by default is not setup in the shared folder. This is a performance issue. Running the project from the shared folder is extremely slow. To avoid this we will set up the project under /var/www folder, and we will sync it back to windows using rsync script which is shipped with the box. To do that

	cd /var/www/example
	./bin/sync.sh

this will sync contents of /var/www/example to /vagrant/example-project. /vagrant is mounted folder to your machine. So you can set up your PHP storm to use the files in that filder, but sync the files on change through SFTP back into box. This is a little inconvenient way, but at least the performance is bearable.

Whenever you generate some files inside the box (manually edit, fetch from git, or perform some symfony console command), please, always, sync back the changes to the windows box.




## Known Issues:

- Symfony version is hardcoded
- There's only Symfony installation available, may also provide Silex as an option
- Nginx installation should be optional in favor of PHP built-in server
- DRY out manifests, wiser submodule decision
- No ability to setup multiple projects per box
- Few configuration options in the box json. (port, folder mappings, NFS option, etc). The idea is to keep the user away from Vagrantfile.
- Syncing sucks (therefore testing sshfs option at the moment)
