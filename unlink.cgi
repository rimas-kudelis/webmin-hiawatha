#!/usr/bin/perl
# Remove link to virtual server

require './hiawatha-lib.pl';
&ReadParse();

my $file = "$server_root/$config{'virt_dir'}/$in{'vhost'}";
if (!-e $file) {
  $file = "$server_root/$in{'vhost'}";
}

#print &text('_header', "<tt>$file</tt>"),"<p>\n";

# delete symlink for Debian style
  my $err = &delete_webfile_link($file);

#&ui_print_header(undef, $text{'_title'}, "");
&webmin_log("virts", "unlinked", $in{'vhost'});
&redirect("");
