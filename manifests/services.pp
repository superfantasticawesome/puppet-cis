# class cis::services
class cis::services inherits cis::params {
  require cis::packages

  cis::services::apply { $cis::params::services: }
}

define cis::services::apply {
  if ! defined(Service["${name}"]) {
    service{ "${name}":
      ensure => 'running',
      enable => true,
    }
  }
}
