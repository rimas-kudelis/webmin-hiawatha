#!/usr/bin/perl
# reload.cgi
# reload Hiawatha config file or restart Hiawatha

require './hiawatha-lib.pl';
&ReadParse();

my $err = &test_config();
&error($err."will not reload") if ($err);
my $err = &reload_hiawatha();
&error($err) if ($err);
sleep(1);
&webmin_log("apply");
&redirect($in{'redir'});
