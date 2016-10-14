#!/usr/bin/perl
# create_server.cgi
# Create a new virtual host.

require './hiawatha-lib.pl';
&ReadParseMime();

my $file = "$server_root/$config{'virt_dir'}/$in{'newserver'}";
if (-e $file) {
  &error("This file already exists.");
}

&lock_file($file);
$temp = &transname();
&copy_source_dest($file, $temp);
$in{'directives'} =~ s/\r//g;
$in{'directives'} =~ s/\s+$//;
@dirs = split(/\n/, $in{'directives'});
$lref = &read_file_lines($file);
if (!defined($start)) {
  $start = 0;
  $end = @$lref - 1;
}
splice(@$lref, $start, $end-$start+1, @dirs);
&flush_file_lines();

my $err = &test_config();
&error($err."config errors, probably with your newest host.") if ($err);

unlink($temp);
&unlock_file($file);
&webmin_log($logtype, "manual", $logname, \%in);

# create symlink for Debian style
&create_webfile_link($file);

if (!-e "$server_root/sites-enabled/$in{'newserver'}") {
  &error("Symlink couldn't be created.");
}
&webmin_log("virt", "create", $file, \%in);

&redirect("");
