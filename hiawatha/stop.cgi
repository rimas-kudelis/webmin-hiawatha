#!/usr/bin/perl
# stop.cgi
# Stop the running Hiawatha server

require './hiawatha-lib.pl';
&ReadParse();

my $err = &stop_hiawatha();
&error($err) if ($err);
sleep(1);
&webmin_log("stop");
&redirect($in{'redir'});
