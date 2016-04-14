#!/usr/bin/perl
# Delete of virtual servers

require './nginx-lib.pl';
&ReadParse();

my $file = "$server_root/$config{'virt_dir'}/$in{'vhost'}";
if (!-e $file) {
	$file = "$server_root/$in{'vhost'}";
}

# delete symlink for Debian style
my $err = &create_webfile_link($file);
if ($err) {
	&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1, undef,
		&restart_button()."<br>".
		&help_search_link("nginx", "man", "doc", "google"), undef, undef,
		&text('index_version', $nginfo{'version'}));

		&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);
		&error($err);
}
&error($err) if ($err);

&webmin_log("mklink", $file, $err);
&redirect("");
