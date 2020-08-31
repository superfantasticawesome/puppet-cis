class cis::banned inherits cis::params {
  require cis::services

  cis::banned::service { $cis::params::disabled: }
  cis::banned::package { $cis::params::banned: }
}

define cis::banned::service {
  if ! defined(Service["${name}"]) {
     service { "${name}": ensure => 'stopped', enable => false, }
  }
}

define cis::banned::package {
  if ! defined(Package["${name}"]) {
    case $name {
      /^(ypbind|yp-tools)$/: { $ensure = 'purged' }
      default: { $ensure = 'absent' }
    } 
    package { "${name}": ensure => $ensure, }
  }
}
