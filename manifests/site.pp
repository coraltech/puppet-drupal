
define drupal::site (

  $domain                  = $name,
  $aliases                 = '',
  $repo_name               = "${name}.git",
  $source                  = undef,
  $revision                = 'master',
  $git_home                = $git::params::home,
  $git_user                = $git::params::user,
  $git_group               = $git::params::group,
  $doc_root                = "${apache::params::web_home}/${name}",
  $configure_firewall      = true,
  $vhost_ip                = $apache::params::vhost_ip,
  $vhost_priority          = $apache::params::priority,
  $vhost_options           = $apache::params::options,
  $http_port               = $apache::params::http_port,
  $use_ssl                 = $apache::params::use_ssl,
  $ssl_cert                = undef,
  $ssl_key                 = undef,
  $https_port              = $apache::params::https_port,
  $vhost_log_dir           = $apache::params::apache_log_dir,
  $error_log_level         = undef,
  $rewrite_log_level       = undef,
  $admin_email             = undef,
  $vhost_http_template     = $apache::params::http_template,
  $vhost_https_template    = $apache::params::https_template,
  $apache_user             = $apache::params::user,
  $apache_group            = $apache::params::group,
  $use_make                = true,
  $make_file               = 'drupal-org.make',
  $include_repos           = false,
  $release_dir             = "${apache::params::web_home}/releases",
  $build_dir               = undef,
  $site_dir                = 'default',
  $files_dir               = undef,
  $databases               = undef,
  $base_url                = undef,
  $cookie_domain           = undef,
  $session_max_lifetime    = undef,
  $session_cookie_lifetime = undef,
  $pcre_backtrack_limit    = undef,
  $pcre_recursion_limit    = undef,
  $ini_settings            = undef,
  $conf                    = undef,
  $settings_template       = 'drupal/settings.php.erb',

) {

  #-----------------------------------------------------------------------------

  $build_dir_real = $build_dir ? {
    undef   => $doc_root,
    default => $build_dir,
  }

  $repo_dir_real = $use_make ? {
    true    => $git_home ? {
      undef   => "${repo_name}.git",
      default => "${git_home}/${repo_name}.git",
    },
    default => $build_dir_real,
  }

  $repo_name_real = $git_home ? {
    undef   => $repo_dir_real,
    default => $repo_name,
  }

  #-----------------------------------------------------------------------------
  # Apache configurations

  apache::vhost { $domain:
    aliases            => $aliases,
    doc_root           => $doc_root,
    configure_firewall => $configure_firewall,
    vhost_ip           => $vhost_ip,
    priority           => $vhost_priority,
    options            => $vhost_options,
    http_port          => $http_port,
    use_ssl            => $use_ssl,
    ssl_cert           => $ssl_cert,
    ssl_key            => $ssl_key,
    https_port         => $https_port,
    log_dir            => $vhost_log_dir,
    error_log_level    => $error_log_level,
    rewrite_log_level  => $rewrite_log_level,
    admin_email        => $admin_email,
    http_template      => $vhost_http_template,
    https_template     => $vhost_https_template,
  }

  #-----------------------------------------------------------------------------
  # Drupal repository (pre processing)

  git::repo { $repo_name_real:
    user     => $git_user,
    group    => $git_group,
    home     => $git_home,
    source   => $source,
    revision => $revision,
    base     => false,
  }

  exec { "check-${domain}":
    path      => [ '/bin', '/usr/bin' ],
    cwd       => $repo_dir_real,
    command   => "git rev-parse HEAD > ${repo_dir_real}/.git/_COMMIT",
    require   => Class['git'],
    subscribe => Git::Repo[$repo_name_real],
  }

  if $use_make {
    #---------------------------------------------------------------------------
    # Distribution releases with drush make

    Exec["check-${domain}"] ->
    Exec["make-release-${domain}"] ->
    Exec["copy-release-${domain}"] ->
    Exec["link-release-${domain}"] ->
    File["save-${domain}"]

    $date_time_str      = strftime("%F-%R")
    $domain_release_dir = "$release_dir/$date_time_str"

    $test_git_cmd       = "diff ${repo_dir_real}/.git/_COMMIT ${repo_dir_real}/.git/_COMMIT.last"
    $test_release_cmd   = "test -d '${domain_release_dir}'"

    $working_copy = $include_repos ? {
      true    => '--working-copy',
      default => '',
    }

    exec { "make-release-${domain}":
      path      => [ '/bin', '/usr/bin' ],
      command   => "drush make ${working_copy} '${repo_dir_real}/${make_file}' '${domain_release_dir}'",
      creates   => $domain_release_dir,
      unless    => $test_git_cmd,
      require   => [ Class['drupal'], Apache::Vhost[$domain] ],
      subscribe => Exec["check-${domain}"],
    }

    exec { "copy-release-${domain}":
      path        => [ '/bin', '/usr/bin' ],
      command     => "cp -Rf '${repo_dir_real}' '${domain_release_dir}/profiles/${repo_name}'",
      onlyif      => $test_release_cmd,
      subscribe   => Exec["make-release-${domain}"],
    }

    exec { "link-release-${domain}":
      path        => [ '/bin', '/usr/bin' ],
      command     => "rm -f '${doc_root}'; ln -s '${domain_release_dir}' '${doc_root}'",
      onlyif      => $test_release_cmd,
      subscribe   => Exec["copy-release-${domain}"],
    }

    file { "secure-site-${domain}":
      path      => "${doc_root}/sites/${site_dir}",
      ensure    => 'directory',
      owner     => $apache_user,
      group     => $apache_group,
      mode      => 770,
      subscribe => Exec["link-release-${domain}"],
    }
  }
  else {
    #---------------------------------------------------------------------------
    # Git repositories

    file { $doc_root:
      ensure    => 'directory',
      owner     => $apache_user,
      group     => $apache_group,
      ignore    => '.git',
      recurse   => true,
      subscribe => Exec["check-${domain}"],
    }

    file { "secure-site-${domain}":
      path      => "${doc_root}/sites/${site_dir}",
      ensure    => 'directory',
      owner     => $apache_user,
      group     => $apache_group,
      mode      => 770,
      subscribe => File[$doc_root],
    }
  }

  #-----------------------------------------------------------------------------
  # Drupal settings

  file { "configure-${domain}":
    path      => "${doc_root}/sites/${site_dir}/settings.php",
    ensure    => 'present',
    owner     => $apache_user,
    group     => $apache_group,
    mode      => 660,
    content   => template($settings_template),
    subscribe => File["secure-site-${domain}"],
  }

  #-----------------------------------------------------------------------------
  # Drupal files

  if $files_dir {
    file { "files-${domain}":
      path      => "${doc_root}/sites/${site_dir}/files",
      ensure    => 'link',
      target    => $files_dir,
      owner     => $apache_user,
      group     => $apache_group,
      force     => true,
      subscribe => File["secure-site-${domain}"],
    }
  }
  else {
    file { "files-${domain}":
      path      => "${doc_root}/sites/${site_dir}/files",
      ensure    => 'directory',
      owner     => $apache_user,
      group     => $apache_group,
      mode      => 770,
      subscribe => File["secure-site-${domain}"],
    }
  }

  #-----------------------------------------------------------------------------
  # Drupal repository (post processing)

  file { "save-${domain}":
    path      => "${repo_dir_real}/.git/_COMMIT.last",
    owner     => 'root',
    group     => 'root',
    mode      => 664,
    source    => "${repo_dir_real}/.git/_COMMIT",
    subscribe => Exec["check-${domain}"],
  }

  #-----------------------------------------------------------------------------

}
