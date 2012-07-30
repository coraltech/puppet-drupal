
class drupal::params {

  include drupal::default

  #-----------------------------------------------------------------------------
  # General configurations

  if $::hiera_ready {
    $drush_package           = hiera('drupal_drush_package', $drupal::default::drush_package)
    $drush_ensure            = hiera('drupal_drush_ensure', $drupal::default::drush_ensure)
    $drush_source            = hiera('drupal_drush_source', $drupal::default::drush_source)
    $aliases                 = hiera('drupal_aliases', $drupal::default::aliases)
    $use_make                = hiera('drupal_use_make', $drupal::default::use_make)
    $repo_name               = hiera('drupal_repo_name', $drupal::default::repo_name)
    $source                  = hiera('drupal_source', $drupal::default::source)
    $revision                = hiera('drupal_revision', $drupal::default::revision)
    $make_file               = hiera('drupal_make_file', $drupal::default::make_file)
    $include_repos           = hiera('drupal_include_repos', $drupal::default::include_repos)
    $server_user             = hiera('drupal_server_user', $drupal::default::server_user)
    $server_group            = hiera('drupal_server_group', $drupal::default::server_group)
    $site_dir                = hiera('drupal_site_dir', $drupal::default::site_dir)
    $site_ip                 = hiera('drupal_site_ip', $drupal::default::site_ip)
    $admin_email             = hiera('drupal_admin_email', $drupal::default::admin_email)
    $files_dir               = hiera('drupal_files_dir', $drupal::default::files_dir)
    $databases               = hiera_hash('drupal_databases', $drupal::default::databases)
    $base_url                = hiera('drupal_base_url', $drupal::default::base_url)
    $cookie_domain           = hiera('drupal_cookie_domain', $drupal::default::cookie_domain)
    $session_max_lifetime    = hiera('drupal_session_max_lifetime', $drupal::default::session_max_lifetime)
    $session_cookie_lifetime = hiera('drupal_session_cookie_lifetime', $drupal::default::session_cookie_lifetime)
    $pcre_backtrack_limit    = hiera('drupal_pcre_backtrack_limit', $drupal::default::pcre_backtrack_limit)
    $pcre_recursion_limit    = hiera('drupal_pcre_recursion_limit', $drupal::default::pcre_recursion_limit)
    $ini_settings            = hiera_hash('drupal_ini_settings', $drupal::default::ini_settings)
    $conf                    = hiera_hash('drupal_conf', $drupal::default::conf)
  }
  else {
    $drush_package           = $drupal::default::drush_package
    $drush_ensure            = $drupal::default::drush_ensure
    $drush_source            = $drupal::default::drush_source
    $aliases                 = $drupal::default::aliases
    $use_make                = $drupal::default::use_make
    $repo_name               = $drupal::default::repo_name
    $source                  = $drupal::default::source
    $revision                = $drupal::default::revision
    $make_file               = $drupal::default::make_file
    $include_repos           = $drupal::default::include_repos
    $server_user             = $drupal::default::server_user
    $server_group            = $drupal::default::server_group
    $site_dir                = $drupal::default::site_dir
    $site_ip                 = $drupal::default::site_ip
    $admin_email             = $drupal::default::admin_email
    $files_dir               = $drupal::default::files_dir
    $databases               = $drupal::default::databases
    $base_url                = $drupal::default::base_url
    $cookie_domain           = $drupal::default::cookie_domain
    $session_max_lifetime    = $drupal::default::session_max_lifetime
    $session_cookie_lifetime = $drupal::default::session_cookie_lifetime
    $pcre_backtrack_limit    = $drupal::default::pcre_backtrack_limit
    $pcre_recursion_limit    = $drupal::default::pcre_recursion_limit
    $ini_settings            = $drupal::default::ini_settings
    $conf                    = $drupal::default::conf
  }

  #-----------------------------------------------------------------------------
  # Operating system specific configurations

  case $::operatingsystem {
    debian, ubuntu: {
      $os_home              = '/var/www'
      $os_build_dir         = ''
      $os_release_dir       = "${os_home}/releases"

      $os_settings_template = 'drupal/settings.php.erb'
    }
    default: {
      fail("The drupal module is not currently supported on ${::operatingsystem}")
    }
  }
}
