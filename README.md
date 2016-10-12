# webmin-hiawatha

You are looking at the Webmin module for managing Hiawatha web server. Currently, it has the following functionality:
- start, stop and restart Hiawatha
- test config before (re)starting
- edit Hiawatha configuration files (namely, `hiawatha.conf`, `cgi-wrapper.conf`, and `mimetype.conf`)
- list, view, create, edit, enable, disable and delete virtual hosts

## Installation

**Note: I looked up all paths in a Debian server. They might be different in other distributions and/or operating systems. Be smart and adapt them if necessary.**

To install, place all files in `/usr/share/webmin/hiawatha/`, then enable the module for the users which should have access to it (I edited /etc/webmin/webmin.acl to achieve that, but I suspect it should be doable from the web interface as well).

Virtual hosts managed by this module will be stored in their own snippet files in `/etc/hiawatha/sites-available/`, and enabled by creating symlinks in `/etc/hiawatha/sites-enabled/`. You should create these directories as root:
```
sudo mkdir /etc/hiawatha/sites-available/
sudo mkdir /etc/hiawatha/sites-enabled/
```
Most people who have run a web server under Debian or Ubuntu should find this setup quiet familiar and convenient. Then to make it actually work in Hiawatha, you have to add the following line at the end of `/etc/hiawatha/hiawatha.conf`:
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

If you found a bug, or have a feature in mind, feel free to open an issue or create a pull request here. However, bear in mind that I don't plan to spend much time on this project, so I'm not making any promises regarding support (and PR's are preferred).

Also, I'm looking for (co-)maintainers for this module, so if you are interested, please let me know.

## Credits
 
This module is based on [NginX module for Webmin](https://github.com/git-matt/webmin-nginx) by Justin Hoffman and @git-matt.
