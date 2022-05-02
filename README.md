# webmin-hiawatha

You are looking at the Webmin module for managing Hiawatha web server. Currently, it has the following functionality:
- start, stop and restart Hiawatha
- test config before (re)starting
- edit Hiawatha configuration files (namely, `hiawatha.conf`, `cgi-wrapper.conf`, and `mimetype.conf`)
- list, view, create, edit, enable, disable and delete virtual hosts

## Installation

It's probably easiest to use the Webmin Configuration module to add Hiawatha module to your setup. You can either download a release package from GitHub, or build one yourself using the supplied `makepackage.sh` script (note you have to run it while in the directory in which it resides). The script will create a `hiawatha.wbm.gz` file for you.

To install the module, do the following:

1. Login to Webmin as root and go to Webmin → Webmin Configuration → Webmin Modules.
2. In the Install tab (default), choose how you want to install the file: if you have it on your server, choose "From local file" and navigate to it, otherwise choose "From uploaded file" and upload it from your computer.
3. List Webmin users to whom you want to grant access to this plugin, or select "Grant access to all Webmin users".
4. Click "Install Module".

After performing these steps, you should find this plugin in the Servers category. There are a few additional steps to perform though, so read on.

**Note: I looked up the paths below on a Debian server. They might be different in other distributions and/or operating systems. Be smart and adapt them if necessary.**

Virtual hosts managed by this module will be stored in their own snippet files in `/etc/hiawatha/sites-available/`, and enabled by creating symlinks in `/etc/hiawatha/sites-enabled/`. You should create these directories as root:
```
sudo mkdir /etc/hiawatha/sites-available/
sudo mkdir /etc/hiawatha/sites-enabled/
```
Most people who have run a web server under Debian or Ubuntu should find this setup quite familiar and convenient. Then to make it actually work in Hiawatha, you have to add the following line at the end of `/etc/hiawatha/hiawatha.conf`:
```
Include sites-enabled
```
In fact, you can do this from within Webmin as well. See Usage below. Once it is done, I suggest you to move VirtualHost blocks one by one away from the main configuration file to their own snippet files (use the Create Virtual Host tab for that). 

## Usage

You will find this module in the Servers category. The module UI has three tabs:

1. Global Configuration – allows editing Hiawatha configuration files and checking server details
2. Existing Virtual Hosts – lists all virtual hosts, allows enabling, disabling, editing and deleting them. The three buttons at the bottom of this tab (Enable, Disable, Delete Servers) apply only to checked rows. Delete is irreversible, so use with caution. Individual hosts can be enabled or disabled right in the table (just click on Yes or No in the Enabled column to toggle).
3. Create Virtual Host – you know what it does

The Module Config button (should be at the top left of the module UI) allows configuring certain settings for the module, such as new virtual host template, config file locations etc. On the top right, you should see buttons to start/stop/restart Hiawatha and to look for help.

## Help, Support and Contributing

I HAVE NO PLANS TO MAINTAIN THIS MODULE MYSELF, since I'm using neither Hiawatha nor Webmin. That's why this repository is currently archived. If you're intrested in becoming the maintainer of this project yourself, or want to make a pull request, please let me know via my email (you'll find it at the top of `git log`).

## Credits
 
This module is based on NginX module for Webmin [by Justin Hoffman](https://www.justindhoffman.com/project/nginx-webmin-module) with [improvements by Matt Scott](https://github.com/git-matt/webmin-nginx). It was adapted for Hiawatha by [Rimas Kudelis](https://github.com/rimas-kudelis).
