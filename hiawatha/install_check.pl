# install_check.pl

do 'hiawatha-lib.pl';

# is_installed(mode)
# For mode 1, returns 2 if the server is installed and configured for use by
# Webmin, 1 if installed but not configured, or 0 otherwise.
# For mode 0, returns 1 if installed, 0 if not
sub is_installed
{
  local @st = stat($config{'hiawatha_path'});
  return 0 if (!@st);
  if (!$config{'hiawatha_version'}) {
    return 0 if (!&get_hiawatha_info(\$dummy));
  }
  return $_[0] ? 2 : 1;
}
