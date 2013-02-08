
define drupal::site (

  $domain                  = $name,
  $aliases                 = $drupal::params::aliases,
  $home                    = $drupal::params::home,
  $build_dir               = $drupal::params::build_dir,
  $release_dir             = $drupal::params::release_dir,
  $use_make                = $drupal::params::use_make,
  $repo_name               = $drupal::params::repo_name,
  $git_home                = $git::params::home,
  $git_user                = $git::params::user,
  $git_group               = $git::params::group,
  $source                  = $drupal::params::source,
  $revision                = $drupal::params::revision,
  $make_file               = $drupal::params::make_file,
  $include_repos           = $drupal::params::include_repos,
  $server_user             = $drupal::params::server_user,
  $server_group            = $drupal::params::server_group,
  $site_dir                = $drupal::params::site_dir,
  $settings_template       = $drupal::params::settings_template,
  $site_ip                 = $drupal::params::site_ip,
  $admin_email             = $drupal::params::admin_email,
  $files_dir               = $drupal::params::files_dir,
  $databases               = $drupal::params::databases,
  $base_url                = $drupal::params::base_url,
  $cookie_domain           = $drupal::params::cookie_domain,
  $session_max_lifetime    = $drupal::params::session_max_lifetime,
  $session_cookie_lifetime = $drupal::params::session_cookie_lifetime,
  $pcre_backtrack_limit    = $drupal::params::pcre_backtrack_limit,
  $pcre_recursion_limit    = $drupal::params::pcre_recursion_limit,
  $ini_settings            = $drupal::params::ini_settings,
  $conf                    = $drupal::params::conf,

) {

  #-----------------------------------------------------------------------------

  $build_dir_real = $build_dir ? {
    ''      => $home,
    default => $build_dir,
  }

  $repo_dir_real = $use_make ? {
    'true'    => $git_home ? {
      ''        => "${repo_name}.git",
      default   => "${git_home}/${repo_name}.git",
    },
    default => $build_dir_real,
  }

  $repo_name_real = $git_home ? {
    ''      => $repo_dir_real,
    default => "${repo_name}.git",
  }

  #---

  File {
    owner => $server_user,
    group => $server_group,
  }

  #-----------------------------------------------------------------------------
  # Drupal repository (pre processing)

  if $use_make {
    #Git::Repo {
    #  notify => Exec["make-release-${domain}"],
    #}
  }

  git::repo { $repo_name_real:
    user     => $git_user,
    group    => $git_group,
    home     => $git_home,
    source   => $source,
    revision => $revision,
    base     => false,
  }

  if $use_make {
    #---------------------------------------------------------------------------
    # Distribution releases with drush make

    $date_time_str      = strftime("%F-%R")
    $domain_release_dir = "$release_dir/$date_time_str"

    $working_copy       = $include_repos ? {
      'true'             => '--working-copy',
      default            => '',
    }

    exec { "make-release-${domain}":
      path        => [ '/bin', '/usr/bin' ],
      command     => "drush make ${working_copy} '${repo_dir_real}/${make_file}' '${domain_release_dir}'",
      creates     => $domain_release_dir,
      require     => [ File['drupal-releases'], Git::Repo[$repo_name_real] ],
    }

    exec { "copy-release-${domain}":
      path        => [ '/bin', '/usr/bin' ],
      command     => "cp -Rf '${repo_dir_real}' '${domain_release_dir}/profiles/${repo_name}'",
      refreshonly => true,
      subscribe   => Exec["make-release-${domain}"],
    }

    exec { "link-release-${domain}":
      path        => [ '/bin', '/usr/bin' ],
      command     => "rm -f '${home}'; ln -s '${domain_release_dir}' '${home}'",
      refreshonly => true,
      subscribe   => Exec["copy-release-${domain}"],
      notify      => [ File["config-${domain}"], File["files-${domain}"] ],
    }
  }

  #-----------------------------------------------------------------------------
  # Drupal settings

  file { "config-${domain}":
    path      => "${home}/sites/${site_dir}/settings.php",
    mode      => 0660,
    content   => template($settings_template),
  }

  #-----------------------------------------------------------------------------
  # Drupal files

  if $files_dir {
    file { "files-${domain}":
      path      => "${home}/sites/${site_dir}/files",
      ensure    => link,
      target    => $files_dir,
      force     => true,
    }
  }
  else {
    file { "files-${domain}":
      path      => "${home}/sites/${site_dir}/files",
      ensure    => directory,
      mode      => 0770,
    }
  }
}
