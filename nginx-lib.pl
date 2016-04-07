#!/usr/bin/perl
# nginx-lib.pl
# Common functions for nginx configuration

BEGIN { push(@INC, ".."); };
use WebminCore;
use File::Basename;
use Data::Dumper;#**
init_config();

#used in edit server and create server (maybe more)
#must go away
our $server_root = $config{'nginx_dir'};
our %nginfo = &get_nginx_info();

#simple list of files in sites-available
sub get_servers
{
	my $dir = "$config{'nginx_dir'}/$config{'virt_dir'}";
  my @files = grep{-f $_}glob("$dir/*");
return @files;
}

# gets info from running nginx
sub get_nginx_info
{
  my $info = &backquote_command("nginx -V 2>&1");
  my @args = split(/--/,$info);
  my %vars;
  my $i = 0;
  foreach (@args) {
    if ($_ =~ /version/) {
      my @a = split(/\//,$_);
#      my @ver = split(' ',@a[1]);
      my @ver = split(' ',$a[1]);
#      $vars{'version'} = @ver[0];
      $vars{'version'} = $ver[0];
    }
    elsif ($_ =~ /=/) {
      my @a = split(/=/,$_);
#      $vars{@a[0]} = @a[1];
      $vars{$a[0]} = $a[1];
    }
    else {
      $vars{"extra_info-$i"} = $_;
      $i++;
    }
  }
  return %vars;
}

sub is_nginx_running
{
  my $pidfile = &get_pid_file();
  return &check_pid_file($pidfile);
}

sub get_pid_file
{
# what about when the pid isnt in config or nginx?
  return $config{'pid_file'} if ($config{'pid_file'});
  return $nginfo{'pid-path'} if ($nginfo{'pid-path'});
}

sub restart_button
{
  my $rv;
  $args = "redir=".&urlize(&this_url());
  my @rv;
  if (&is_nginx_running()) {
#    push(@rv, "<a href=\"reload.cgi?$args\">$text{'nginx_apply'}</a>\n");
    #push(@rv, "<a href=\"restart.cgi?$args\">$text{'nginx_restart'}</a>\n");
    push(@rv, "<a href=\"restart.cgi?$args\">$text{'nginx_apply'}</a>\n");
    push(@rv, "<a href=\"stop.cgi?$args\">$text{'nginx_stop'}</a>\n");
  }
  else {
    push(@rv, "<a href=\"start.cgi?$args\">$text{'nginx_start'}</a>\n");
  }
  return join("<br>\n", @rv);
}

# Attempts to stop the running nginx process
sub stop_nginx
{
  my ($out,$cmd);
  if ($config{'stop_cmd'} == 1) {
    $cmd = "/etc/init.d/nginx stop";
  }
  elsif ($config{'stop_cmd'} == 2) {
    # use nginx_path
    $cmd = "$config{'nginx_path'} -s quit";
  }
  elsif ($config{'stop_cmd'} == 3) {
    # use systemd
    $cmd = "systemctl stop nginx";
  }
  elsif ($config{'stop_cmd'}) {
    # use the configured stop command
    $cmd = $config{'stop_cmd'};
  }

  if ($cmd) {
    $out = &backquote_logged("($cmd) 2>&1");
    if ($?) {
      return "<pre>".&html_escape($out)."</pre>";
    }
  }
  else {
    # kill the process if nothing else works
    my $pid = &is_nginx_running() || return &text('stop_epid');
    &kill_logged('TERM', $pid) || return &text('stop_esig', $pid);
  }
  return undef;
}

# Attempts to start nginx
sub start_nginx
{
  my ($out,$cmd);
  # stop nginx if running
  if (&is_nginx_running()) {
    my $err = &stop_nginx();
    &error($err) if ($err);
    &webmin_log("stop");
  }

  if ($config{'start_cmd'} == 1) {
    $cmd = "/etc/init.d/nginx start";
  }
  elsif ($config{'start_cmd'} == 2) {
    # use nginx_path
    $cmd = $config{'nginx_path'};
  }
  elsif ($config{'start_cmd'} == 3) {
    $cmd = "systemctl start nginx";
  }
  elsif ($config{'start_cmd'}) {
    # use the configured start command
    $cmd = $config{'start_cmd'};
  }
  else {
    $cmd = $config{'nginx_path'};
  }

  &clean_environment();
  $out = &backquote_logged("($cmd) 2>&1");
  &reset_environment();
  if ($?) {
    return "<pre>".&html_escape($out)."</pre>";
  }
  return undef;
}

# Attempts to reload config files
sub reload_nginx
{
  my ($out,$cmd);
  if ($config{'apply_cmd'} == 1) {
    $cmd = "/etc/init.d/nginx reload";
  }
  elsif ($config{'apply_cmd'} == 2) {
    # use nginx_path
    $cmd = "$config{'nginx_path'} -s reload";
  }
  else {
    # restart nginx
    &start_nginx();
    return undef;
  }

  &clean_environment();
  $out = &backquote_logged("($cmd) 2>&1");
  &reset_environment();
  if ($?) {
    return "<pre>".&html_escape($out)."</pre>";
  }
}

# test config files
sub test_config
{
  return undef;
  if ($config{'test_config'} == 1) {
    my $out = &backquote_command("(/etc/init.d/nginx configtest) 2>&1");
    if ($out =~ /failed/) {
      return "<pre>".&html_escape($out)."</pre>";
    }
    else {
#    elsif ($out =~ /successful/) {
      return undef;
    }
    return $text{'test_err'};
  }
  return undef;
}

# Creates a link in the debian-style link directory for a new website's file
sub create_webfile_link
{
  my ($file, @array) = @_;
  my $name = basename($file);
  my $link = "$server_root/$config{'link_dir'}$name";
  &lock_file($file);
#	$ret = "linking $file to $link...";
  symlink($file, $link);
  &unlock_file($file);
#	return $ret;
}

# delete link to sites available
sub delete_webfile_link
{
  my ($file, @array) = @_;
  my $name = basename($file);
  my $link = "$server_root/$config{'link_dir'}$name";
#	$ret = "removing $link...";
# test if symlink already deleted
 if (!-l $link) {
   return undef;
 }
 &lock_file($link);
 unlink($link);
 &unlock_file($link);
# test symlink deleted
  if (-l $link) {
#    return "${ret}The link for $_ was not removed.";
    return "The link for $_ was not removed.";
  }
}

# turns list of icons into link,text,icon table
sub config_icons
{
local (@titles, @links, @icons);
for($i=0; $i<@_; $i++) {
		push(@links, $_[$i]->{'link'});
		push(@titles, $_[$i]->{'name'});
		push(@icons, $_[$i]->{'icon'});
	}
&icons_table(\@links, \@titles, \@icons, 3);
print "<p>\n";
}

#gives this url
sub this_url
{
  my $url;
  $url = $ENV{'SCRIPT_NAME'};
  if ($ENV{'QUERY_STRING'} ne "") { $url .= "?$ENV{'QUERY_STRING'}"; }
  return $url;
}

sub parse_config
{
	local (%found, $temp, $fname, @params);

	$fname = shift;
	while (my $temp = shift) {
		push (@params, $temp);
	}	# insert each other argument into array
	open FILE, $fname or die "Couldn't open file: $!"; 
	while (my $line = <FILE>) {
		chop;
		$line =~ s/^\s*#.*$//g;
		foreach $a (@params) {
			if ($line =~ /^\s*$a\s*([^;]+);$/) {
				$temp = $1;
				$temp = "" if $i == 0;
#				push (@{$found{$a}}, $1);
				push (@{$found{$a}}, split (" ", $1));
			}
		}
	}
	close FILE;
	return %found;
}

1;

