
class drupal::params {

  #-----------------------------------------------------------------------------

  $drush_pear_channel = 'pear.drush.org'

  case $::operatingsystem {
    debian: {}
    ubuntu: {}
    centos, redhat: {}
  }
}
