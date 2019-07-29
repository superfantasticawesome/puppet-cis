class cis::aide inherits cis::params {
  # See: https://access.redhat.com/discussions/779413
  require cis::prelink
  
  if ($cis::params::manage_aide) {
    case $::operatingsystem {
      'Ubuntu' : {
        $aide_binary = 'aide.wrapper'
        $aide_init   = 'aideinit'
      }
      'OracleLinux', 'RedHat', 'CentOS', 'Fedora', 'Amazon' : {
        $aide_binary = 'aide'
        $aide_init   = 'aide --init'
      }
      default : {
        $aide_binary = 'aide'
        $aide_init   = 'aide --init'
      }
    }
    
    package { 'aide': 
      ensure => 'installed', 
      notify => Exec["/usr/sbin/${aide_init}"],
    } 
    
    cron { 'aide_watch':
      command => "/usr/sbin/${aide_binary} --check",
      user    => root,
      hour    => 5,
      minute  => 0,
      require => Package['aide'],
    }
  
    exec { "/usr/sbin/${aide_init}":
      refreshonly => true,
      timeout     => 0,
    }
    
    # Copy the newly initiailized db for RHEL-based systems
    # NOTE: This isn't necessary for Debian-based systems
    #
    case $::operatingsystem {
      'OracleLinux', 'RedHat', 'CentOS', 'Fedora', 'Amazon' : {
        exec { '/bin/mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz':
          refreshonly => true,
          onlyif      => '/bin/ls /var/lib/aide/aide.db.new.gz',
          subscribe   => Exec["/usr/sbin/${aide_init}"],
        }
      }
      default: {
      }
    }
  }
}
