#!/usr/bin/perl
# Creates the debian-style directory structure

require './nginx-lib.pl';
&ReadParse();

&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

my $avail = $config{'nginx_dir'}.'/sites-available';
my $enbld = $config{'nginx_dir'}.'/sites-enabled';
my $confd = $config{'nginx_dir'}.'/conf.d';
#create virt_link dir
if (!mkdir($enbld)) {
	print "<p>".&text('mk_dirs_fail', $enbld, $!)."</p>";
} else {
	print "<p>".&text('mk_dirs_ok', $enbld)."</p>";
}
#if conf.d/ exists: link to virt_dir otherwise: create virt_dir dir
if (-x $confd) {
	#print "<p>".&text('mk_dirs_exists', $confd)."</p>";
	&lock_file($confd);
	#	$ret = "linking $file to $link...";
	#$symlink_exists = eval { symlink("",""); 1 };
	#symlink($confd, $avail) if ($symlink_exists);
	if (!symlink($confd, $avail)) {
		print "<p>".&text('mk_dirs_linkfail', $confd, $avail, $!)."</p>";
	} else {
		print "<p>".&text('mk_dirs_linkok', $avail)."</p>";
	}
	&unlock_file($confd);
} else {
	if (!mkdir($avail)) {
		print "<p>".&text('mk_dirs_fail', $avail, $!)."</p>";
	} else {
		print "<p>".&text('mk_dirs_ok', $avail)."</p>";
	}
}
&ui_print_footer("$gconfig{'webprefix'}/", $text{'index_return'});