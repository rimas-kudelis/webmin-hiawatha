#!/usr/bin/perl
# hiawatha-lib.pl
# Common functions for Hiawatha configuration

BEGIN { push(@INC, ".."); };
use WebminCore;
use File::Basename;
use Data::Dumper;#**
init_config();

#used in edit server and create server (maybe more)
#must go away
our $server_root = $config{'hiawatha_dir'};
our %server_info = &get_hiawatha_info();

#simple list of files in sites-available
sub get_servers
{
  my $dir = "$config{'hiawatha_dir'}/$config{'virt_dir'}";
  my @files = grep{-f $_}glob("$dir/*");
  return @files;
}

# gets info from running Hiawatha
sub get_hiawatha_info
{
  my $info = &backquote_command("hiawatha -v 2>&1");
  # 10.3 output:
  # Hiawatha v10.3, cache, IPv6, Monitor, reverse proxy, TLS v2.2.1, Tomahawk, URL toolkit, XSLT
  # Copyright (c) by Hugo Leisink <hugo@leisink.net>

  # 10.4 output:
  # Hiawatha v10.4, copyright (c) by Hugo Leisink <hugo@leisink.net>

  my @lines = split(/\n/, $info);
  my @modules = split(/,\s+/, $lines[0]); # ignore the copyright line
  my %vars;
  my $version = shift @modules;
  if ($version =~ /Hiawatha\s+v/) {
    my @a = split(/\sv/,$version);
    my @ver = split(/\s/,$a[1]);
    $vars{'version'} = $ver[0];
  }
  # Versions are compared as strings here, but this should do until with versions 10.0 to 99.
  if ($vars{'version'} >= "10.4") {
    # Separate option to get module list, here's its output:
    # Enabled modules: Cache, ChallengeClient, FileHashes, IPv6, Monitor, ReverseProxy, TLS v2.3.0, ThreadPool, Tomahawk, UrlToolkit, XSLT
    $info = &backquote_command("hiawatha -m 2>&1");
    my @temp = split(/:\s*/, $info);
    @modules = split(/,\s*/, @temp[1]);
  }
  $vars{'modules'} = [ @modules ];
  return %vars;
}

sub is_hiawatha_running
{
  my $pidfile = &get_pid_file();
  return &check_pid_file($pidfile);
}

sub get_pid_file
{
  return $config{'pid_file'} if ($config{'pid_file'});
  #return &server_info{'pid-path'} if ($server_info{'pid-path'});
  # When the pid is not in config or hiawatha output:
  return "/var/run/hiawatha.pid";
}

sub restart_button
{
  my $rv;
  $args = "redir=".&urlize(&this_url());
  my @rv;
  if (&is_hiawatha_running()) {
    #push(@rv, "<a href=\"reload.cgi?$args\">$text{'hiawatha_apply'}</a>\n");
    #push(@rv, "<a href=\"restart.cgi?$args\">$text{'hiawatha_restart'}</a>\n");
    push(@rv, "<a href=\"restart.cgi?$args\">$text{'hiawatha_apply'}</a>\n");
    push(@rv, "<a href=\"stop.cgi?$args\">$text{'hiawatha_stop'}</a>\n");
  }
  else {
    push(@rv, "<a href=\"start.cgi?$args\">$text{'hiawatha_start'}</a>\n");
  }
  return join("<br>\n", @rv);
}

# Attempts to stop the running hiawatha process
sub stop_hiawatha
{
  my ($out,$cmd);
  if ($config{'stop_cmd'} == 1) {
    # use init.d
    $cmd = "/etc/init.d/hiawatha stop";
  }
  elsif ($config{'stop_cmd'} == 2) {
    # use systemd
    $cmd = "systemctl stop hiawatha";
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
    my $pid = &is_hiawatha_running() || return &text('stop_epid');
    &kill_logged('TERM', $pid) || return &text('stop_esig', $pid);
  }
  return undef;
}

# Attempts to start hiawatha
sub start_hiawatha
{
  my ($out,$cmd);
  # stop hiawatha if running
  if (&is_hiawatha_running()) {
    my $err = &stop_hiawatha();
    &error($err) if ($err);
    &webmin_log("stop");
  }

  if ($config{'start_cmd'} == 1) {
    # use init.d
    $cmd = "/etc/init.d/hiawatha start";
  }
  elsif ($config{'start_cmd'} == 2) {
    # use systemd
    $cmd = "systemctl start hiawatha";
  }
  elsif ($config{'start_cmd'}) {
    # use the configured start command
    $cmd = $config{'start_cmd'};
  }
  else {
    # use hiawatha_path
    $cmd = $config{'hiawatha_path'};
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
sub reload_hiawatha
{
  my ($out,$cmd);
  if ($config{'apply_cmd'} == 1) {
    # use init.d
    $cmd = "/etc/init.d/hiawatha restart";
  }
  elsif ($config{'apply_cmd'} == 2) {
    # use systemd
    $cmd = "systemctl restart hiawatha";
  }
  elsif ($config{'apply_cmd'}) {
    # use the configured script command
    $cmd = $config{'apply_cmd'};
  }
  else {
    # restart Hiawatha
    &start_hiawatha();
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
  my ($cmd);
  if ($config{'test_config'} == 0) {
    return undef;
  }
  elsif ($config{'test_cmd'} == 1) {
    # use init.d
    $cmd = "/etc/init.d/hiawatha check";
  }
  elsif ($config{'test_cmd'}) {
    # use the configured script command
    $cmd = $config{'test_cmd'};
  }
  else {
    # use hiawatha_path
    $cmd = "$config{'hiawatha_path'} -k"
  }

  my $out = &backquote_command("($cmd) 2>&1");
  if ($out =~ /Configuration OK/) {
    return undef;
  }
  else {
  #elsif ($out =~ /Syntax error in/) {
    return "<pre>".&html_escape($out)."</pre>";
  }
}

# Creates a link in the debian-style link directory for a new website's file
sub create_webfile_link
{
  my ($file, @array) = @_;
  my $name = basename($file);
  my $file = "$server_root/$config{'virt_dir'}/$name";
  my $link = "$server_root/$config{'link_dir'}/$name";

  &lock_file($file);
  if (!symlink($file, $link)) {
    return "Could not create a link for $name.";
  }
  if (!-l $link) {
    return undef;
  }
  &unlock_file($file);
}

# delete link to sites-available
sub delete_webfile_link
{
  my ($file, @array) = @_;
  my $name = basename($file);
  my $link = "$server_root/$config{'link_dir'}/$name";

  if (!-l $link) {
    return undef;
  }
  &lock_file($link);
  unlink($link);
  &unlock_file($link);

  if (-l $link) {
    return "Could not remove a link for $name.";
  }
}

# delete virtual host along with the link in sites-available
sub delete_virtual_host
{
  my ($file, @array) = @_;
  my $name = basename($file);
  my $file = "$server_root/$config{'virt_dir'}/$name";

  # delete symlink for Debian style
  my $err = &delete_webfile_link($file);

  return $err if ($err);

  # delete file
  unlink($file);

  # test if file was deleted
  if (-e $file) {
    return("Could not delete the virtual server $name.");
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
  } # insert each other argument into array
  open FILE, $fname or die "Couldn't open file: $!";
  while (my $line = <FILE>) {
    chop;
    $line =~ s/^\s*#.*$//g;
    foreach $a (@params) {
      if ($line =~ /^\s*$a\s*=\s*(.+)$/) {
        $temp = $1;
        push (@{$found{$a}}, split ("\s*,\s*", $1));
      }
    }
  }
  close FILE;
  return %found;
}

1;
