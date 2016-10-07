#!/usr/bin/perl
# Disable virtual host

require './hiawatha-lib.pl';
&ReadParse();

# Delete symlink
my $err = &delete_webfile_link($in{'vhost'});
if ($err) {
  &ui_print_header(undef, $text{'index_title'}, "", undef, 1, undef, undef,
    &restart_button()."<br>".
    &help_search_link("hiawatha webserver", "man", "doc", "google"), undef, undef,
    &text('index_version', $server_info{'version'}));

  &error($err);
}

&webmin_log("unlink", $in{'vhost'}, $err);
&redirect("");
