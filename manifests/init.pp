# Class: drupal
#
#   This module configures Drupal environments and manages Drupal sites.
#
#   Adrian Webb <adrian.webb@coraltg.com>
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
#   Provides the drupal::add_site() function.
#
# Requires:
#
# Sample Usage:
#
#   class { 'drupal':
#  }
#
# [Remember: No empty lines between comments and class definition]
class drupal (



) inherits drupal::params {

  #-----------------------------------------------------------------------------
  # Drupal installation

  package { 'drush/drush':
    ensure   => 'latest',
    provider => 'pear',
    source   => "${drupal::params::drush_pear_channel}/drush",
    require  => Class['php'],
  }
}
