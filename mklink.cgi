#!/usr/bin/perl
# Enable virtual host

require './hiawatha-lib.pl';
&ReadParse();

# Create symlink
my $err = &create_webfile_link($in{'vhost'});
if ($err) {
  &ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1, undef,
    &restart_button()."<br>".
    &help_search_link("hiawatha webserver", "man", "doc", "google"), undef, undef,
    &text('index_version', $server_info{'version'}));

  &ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);
  &error($err);
}

&webmin_log("mklink", $in{'vhost'}, $err);
&redirect("");
