# install_check.pl

do 'nginx-lib.pl';

# is_installed(mode)
# For mode 1, returns 2 if the server is installed and configured for use by
# Webmin, 1 if installed but not configured, or 0 otherwise.
# For mode 0, returns 1 if installed, 0 if not
sub is_installed
{
local @st = stat($config{'nginx_path'});
return 0 if (!@st);
if (!$config{'nginx_version'}) {
#    || $st[7] != $config{'nginx_size'} || $st[9] != $config{'nginx_mtime'}) {
	# Version is not cached - need to actually check
	return 0 if (!&get_nginx_info(\$dummy));
	}
return $_[0] ? 2 : 1;
}

