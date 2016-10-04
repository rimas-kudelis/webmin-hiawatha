#!/usr/bin/perl
# start.cgi
# Start Hiawatha

require './hiawatha-lib.pl';
&ReadParse();

my $err = &test_config();
&error($err."will not start") if ($err);
my $err = &start_hiawatha();
&error($err) if ($err);
sleep(1);
&webmin_log("start");
&redirect($in{'redir'});
