# Class: drupal
#
#   This module configures Drupal environments and manages Drupal sites.
#
#   Adrian Webb <adrian.webb@coraltech.net>
#   2012-05-22
#
#   Tested platforms:
#    - Ubuntu 12.04
#
# Parameters:
#
#
# Actions:
#
#   Configures Drupal environments and manages sites.
#
#   Provides the drupal::site() definition.
#
# Requires:
#
# Sample Usage:
#
#  class { 'drupal':
#
#  }
#
# [Remember: No empty lines between comments and class definition]
class drupal (

  $drush_package  = $drupal::params::drush_package,
  $drush_ensure   = $drupal::params::drush_ensure,
  $drush_source   = $drupal::params::drush_source,
  $release_dir    = $drupal::params::release_dir,

) inherits drupal::params {

  #-----------------------------------------------------------------------------
  # Drupal installation

  package { 'drush':
    name     => $drush_package,
    ensure   => $drush_ensure,
    provider => 'pear',
    source   => $drush_source,
    require  => Class['php'],
  }

  #-----------------------------------------------------------------------------
  # Drupal setup

  file { "drupal-releases":
    path   => $release_dir,
    ensure => directory,
    mode   => 0775,
  }
}
