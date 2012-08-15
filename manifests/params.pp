
class drupal::params inherits drupal::default {

  include git::params

  #-----------------------------------------------------------------------------

  $drush_package           = module_param('drush_package')
  $drush_ensure            = module_param('drush_ensure')
  $drush_source            = module_param('drush_source')

  #---

  $home                    = module_param('home')
  $build_dir               = module_param('build_dir')
  $release_dir             = module_param('release_dir')

  #---

  $settings_template       = module_param('settings_template')

  $aliases                 = module_param('aliases')

  $use_make                = module_param('use_make')
  $repo_name               = module_param('repo_name')
  $source                  = module_param('source')
  $revision                = module_param('revision')
  $make_file               = module_param('make_file')
  $include_repos           = module_param('include_repos')

  $server_user             = module_param('server_user')
  $server_group            = module_param('server_group')

  $site_dir                = module_param('site_dir')
  $site_ip                 = module_param('site_ip')

  $admin_email             = module_param('admin_email')

  $files_dir               = module_param('files_dir')
  $databases               = module_hash('databases')

  $base_url                = module_param('base_url')
  $cookie_domain           = module_param('cookie_domain')
  $session_max_lifetime    = module_param('session_max_lifetime')
  $session_cookie_lifetime = module_param('session_cookie_lifetime')
  $pcre_backtrack_limit    = module_param('pcre_backtrack_limit')
  $pcre_recursion_limit    = module_param('pcre_recursion_limit')

  $ini_settings            = module_hash('ini_settings')
  $conf                    = module_hash('conf')
}
