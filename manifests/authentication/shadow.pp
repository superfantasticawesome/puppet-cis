# class cis::authentication::shadow
#
class cis::authentication::shadow inherits cis::params {
  # CIS Set Shadow Password Suite Parameters
  #

  file { ['/etc/passwd', '/etc/group', '/etc/login.defs']:
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { '/etc/shadow':
    owner => 'root',
    group => 'root',
    mode  => '0640',
  }

  file { '/etc/gshadow':
    owner => 'root',
    group => 'root',
    mode  => '0000',
  }

  # CIS Set Password Expiration Days
  #     Set Password Change Minimum Number of Days
  #     Set Password Expiring Warning Days
  #
  if $manage_local_passwords {
    augeas { 'update login.defs with default password policy':
      context => '/files/etc/login.defs',
      incl    => '/etc/login.defs',
      lens    => 'Login_defs.lns',
      changes => [
        "set /files/etc/login.defs/PASS_MAX_DAYS ${password_max_days}",
        "set /files/etc/login.defs/PASS_MIN_DAYS ${password_min_days}",
        "set /files/etc/login.defs/PASS_WARN_AGE ${password_warn_age}",
      ]
    }
  }

  # CIS Set Default umask for Users
  #
  augeas { 'update login.defs with default umask':
    context => '/files/etc/login.defs',
    incl    => '/etc/login.defs',
    lens    => 'Login_defs.lns',
    changes => "set /files/etc/login.defs/UMASK ${umask_user}",
  }
}
