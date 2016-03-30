#!/usr/bin/perl
# Delete of virtual servers

require './nginx-lib.pl';
&ReadParse();

my @del_serv = split(/\0/,$in{'d'});

foreach (@del_serv) {
  my $file = "$server_root/$config{'virt_dir'}/$_";

# delete file
  unlink($file);

# delete symlink for Debian style
  my $err = &delete_webfile_link($file);
  &error($err) if ($err);

# test if file was deleted
  if (-e $file) {
    &error("The virtual server $_ was not deleted.");
  }
}

&webmin_log("virts", "delete", scalar(@del_serv));
&redirect("");
