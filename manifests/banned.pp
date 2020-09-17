class cis::banned inherits cis::params {
  require cis::services

  $cis::params::disabled.each |string $service| {
    if !defined(Service["${service}"]) {
      service { "${name}": ensure => 'stopped', enable => false, }
    }
  }

  $cis::params::banned.each |string $package| {
    if !defined(Package["${package}"]) {
      case $name {
        /^(ypbind|yp-tools)$/: { $ensure = 'purged' }
        default: { $ensure = 'absent' }
      } 
      package { "${name}": ensure => $ensure, }
    }
  }
}
