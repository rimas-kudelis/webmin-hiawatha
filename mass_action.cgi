#!/usr/bin/perl
# Mass actions on virtual servers

require './hiawatha-lib.pl';
&ReadParse();

my @servers = split(/\0/,$in{'d'});
my @errs;

if ($in{'enable'}) {
  foreach (@servers) {
    my $err = &create_webfile_link($_);
    if ($err) {
      push (@errs, $err);
    }
  }
}
elsif ($in{'disable'}) {
  foreach (@servers) {
    my $err = &delete_webfile_link($_);
    if ($err) {
      push (@errs, $err);
    }
  }
}
elsif ($in{'delete'}) {
  foreach (@servers) {
    my $err = &delete_virtual_host($_);
    if ($err) {
      push (@errs, $err);
    }
  }
}

if (@errs[0]) {
  &ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1, undef,
    &restart_button()."<br>".
    &help_search_link("hiawatha webserver", "man", "doc", "google"), undef, undef,
    &text('index_version', $server_info{'version'}));

  &ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

  &error(@errs);
}

&webmin_log("virts", "delete", scalar(@del_serv));
&redirect("");
