#!/usr/bin/perl
# details.cgi
# Display list of Hiawatha details

require './hiawatha-lib.pl';
&ReadParse();

&ui_print_header($text{'server_details'}, $text{'index_title'}, "", undef, 1, undef, undef,
  &restart_button()."<br>".
  &help_search_link("hiawatha webserver", "man", "doc", "google"), undef, undef,
  &text('index_version', $server_info{'version'}));

  print "$text{'server_version'}: $server_info{'version'}<br><br>";

  print "$text{'enabled_modules'}:<br><ul>";

  foreach(@{ $server_info{'modules'} }) {
    print "<li>$_</li>";
  }

  print "</ul>";

&ui_print_footer($return, $text{'module_index'});
