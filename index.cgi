#!/usr/bin/perl
# index.cgi
# Display a list of all virtual servers, and links for various types

use File::Basename;

require './hiawatha-lib.pl';
&ReadParse();

my %rv;

# add virtual servers
my @virts = &get_servers();
foreach $v (@virts) {
#  $idx = &indexof($v, @$conf);
  $sn = basename($v);
  push (@vidx, $sn);
  push (@vname, $sn);
  push (@vlink, "edit_server.cgi?editfile=$sn");
  push (@link2, "mklink.cgi?vhost=$sn");
  push (@ulink, "unlink.cgi?vhost=$sn");
  %rv = &parse_config ("$config{'hiawatha_dir'}/$config{'virt_dir'}/$sn", "Hostname", "WebsiteRoot", "RequiredBinding", "RequireTLS");
  push (@vaddr, join ($config{'join_ch'}, @{$rv{'Hostname'}}));
  push (@vroot, @{$rv{'WebsiteRoot'}});
  if (@{$rv{'RequiredBinding'}}) {
    push (@vbind, join ($config{'join_ch'}, @{$rv{'RequiredBinding'}}));
  } else {
    push (@vbind, $text{'index_all'});
  }
  if (@{$rv{'Hostname'}}[0]) {
    push(@vurl, (@{$rv{'RequireTLS'}} ? "https://" : "http://") . @{$rv{'Hostname'}}[0] . "/");
  } else {
    push(@vurl, "");
  }
}

# Page header
&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1, undef,
  &restart_button()."<br>".
  &help_search_link("hiawatha webserver", "man", "doc", "google"), undef, undef,
  &text('index_version', $server_info{'version'}));

# Check if Hiawatha is installed
if (!-x $config{'hiawatha_path'}) {
  print &text('index_notfound', $config{'hiawatha_path'}),
    $text{'index_either'}. &text('index_modify',
      "$gconfig{'webprefix'}/config.cgi?$module_name").
    $text{'index_install'};  #, "<p>\n";

  &foreign_require("software", "software-lib.pl");
  $lnk = &software::missing_install_link("hiawatha", $text{'index_hiawatha'},
    "../$module_name/", $text{'index_title'});
  print $lnk,"<p>\n" if ($lnk);

  &ui_print_footer("/", $text{'index_return'});
  exit;
}

## Check if configuration matches which command
# which gets the wrong path!!
#my $whhiawatha = &backquote_command("(which hiawatha) 2>&1");
#if ($whhiawatha ne $config{'hiawatha_path'}) {
#  print &text('index_mismatch', $whhiawatha, $config{'hiawatha_path'}),
#    &text('index_modify', "$gconfig{'webprefix'}/config.cgi?$module_name");
#
#  &ui_print_footer("/", $text{'index_return'});
#  exit;
#}

# Start main display
@tabs = (['global', $text{'tab_global'}], ['existing', $text{'tab_existing_vhosts'}], ['create', $text{'tab_create_vhost'}]);

print ui_tabs_start(\@tabs, 'mode', 'existing');

  print ui_tabs_start_tab('mode', 'global');
    $global_icon = { "icon" => "images/hiawatha_edit.gif",
      "name" => $text{'gl_edit'},
      "link" => "edit_server.cgi?editfile=" . basename($config{'hiawatha_conf'}) };
    $cgiwrapper_icon = { "icon" => "images/hiawatha_edit.gif",
      "name" => $text{'gl_cgiwrapper'},
      "link" => "edit_server.cgi?editfile=" . basename($config{'cgiwrapper_conf'}) };
    $mimetype_icon = { "icon" => "images/hiawatha_edit.gif",
      "name" => $text{'gl_mimetype'},
      "link" => "edit_server.cgi?editfile=" . basename($config{'mimetype_conf'}) };
    $det_icon = { "icon" => "images/hiawatha_details.gif",
      "name" => $text{'gl_details'},
      "link" => "details.cgi" };
    $mk_dirs = { "icon" => "images/files.gif",
      "name" => $text{'gl_dirs'},
      "link" => "mk_dirs.cgi" };
    &config_icons($global_icon, $cgiwrapper_icon, $mimetype_icon, $det_icon);
  print ui_tabs_end_tab('mode', 'global');

  print ui_tabs_start_tab('mode', 'existing');
    @links = ( );
    push(@links, &select_all_link("d"), &select_invert_link("d"));
    print &ui_form_start("mass_action.cgi", "get");
      print &ui_links_row(\@links);
      print &ui_columns_start([
        "",
        $text{'index_name'},
        $text{'index_enabled'},
        $text{'index_addr'},
        $text{'index_root'},
        $text{'index_bind'},
        $text{'index_url'} ], 100);

        for($i=0; $i<@vname; $i++) {
          my @cols;
          push(@cols, "<a href=\"$vlink[$i]\" title=\"$text{'click_edit'}\">$vname[$i]</a>");
          if (-e "$config{'hiawatha_dir'}/$config{'link_dir'}/$vname[$i]") {
            push(@cols, "<a href=\"$ulink[$i]\" title=\"$text{'click_disable'}\">$text{'active'}</a>");
          } else {
            push(@cols, "<a href=\"$link2[$i]\" title=\"$text{'click_enable'}\">$text{'inactive'}</a>");
          }
          push(@cols, &html_escape($vaddr[$i]));
          push(@cols, &html_escape($vroot[$i]));
          push(@cols, &html_escape($vbind[$i]));
          push(@cols, ($vurl[$i] ? "<a href=\"$vurl[$i]\" title=\"$text{'click_visit'}\">$vurl[$i]</a>" : ""));
          print &ui_checked_columns_row(\@cols, undef,"d", $vidx[$i]);
        }

      print &ui_columns_end();
      print &ui_links_row(\@links);
    print &ui_form_end([
      [ "enable", $text{'index_enable'} ],
      [ "disable", $text{'index_disable'} ],
      [ "delete", $text{'index_delete'} ]
      ]);
  print ui_tabs_end_tab('mode', 'existing');

  print ui_tabs_start_tab('mode', 'create');
    print &ui_form_start("create_server.cgi", "form-data");

      print &ui_table_start($text{'index_create'}, undef, 2);
        print &ui_table_row($text{'index_name'},
          &ui_textbox("newserver", undef, 40));

        print &ui_table_row($text{'new_file_contents'},
          &ui_textarea("directives", undef, 25, 80, undef, undef,"style='width:100%'"));

        print &ui_table_row("",
          &ui_submit($text{'save'}));
      print &ui_table_end();
    print &ui_form_end();
  print ui_tabs_end_tab('mode', 'create');

print ui_tabs_end();

ui_print_footer("/", $text{'index'});
