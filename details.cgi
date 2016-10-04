#!/usr/bin/perl
# details.cgi
# Display list of Hiawatha details

require './hiawatha-lib.pl';
&ReadParse();

&ui_print_header($title, "Server Details", "");

  print "Server version: $server_info{'version'}<br><br>";

  print "Compiled with:<br><ul>";

  foreach(@{ $server_info{'modules'} }) {
    print "<li>$_</li>";
  }

  print "</ul>";

&ui_print_footer("$return", "Hiawatha index");
