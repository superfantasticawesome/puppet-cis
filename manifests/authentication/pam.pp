# class cis::authentication::pam
#
class cis::authentication::pam inherits cis::params {

  case $::operatingsystem {
    'OracleLinux', 'RedHat', 'CentOS', 'Fedora' : {
      $pam_password = 'system-auth'
      $pam_auth     = 'password-auth'

      # CIS Upgrade Password Hashing Algorithm to SHA-512
      #
      if ! defined(Package['authconfig']) {
        package { 'authconfig':
          ensure => installed,
        }
      }

      if ! defined(Exec['authconfig --passalgo=sha512 --update']) {
        exec { 'authconfig --passalgo=sha512 --update':
          path    => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'],
          unless  => 'authconfig --test | grep hashing | grep sha512',
          require => Package['authconfig'],
        }
      }

      case $::facts['os']['release']['major'] {
        '7' : {
          # CIS Set Password Creation Requirement Parameters Using pam_pwquality
          #
          $pwquality_settings = {
            "pwquality minlen" => {
              setting          => 'minlen',
              value            => "${$pwquality_minlen}",
            },
            "pwquality dcredit" => {
              setting => 'dcredit',
              value   => "${pwquality_dcredit}",
            },
            "pwquality ucredit" => {
              setting => 'ucredit',
              value   => "${pwquality_ucredit}",
            },
            "pwquality ocredit" => {
              setting => 'ocredit',
              value   => "${pwquality_ocredit}",
            },
            "pwquality lcredit" => {
              setting => 'lcredit',
              value   => "${pwquality_lcredit}",
            },
          }
          if $manage_local_passwords {
            create_resources(cis::authentication::pam::pwquality, $pwquality_settings)
          }

          $pam_settings_for_rhel7 = {
            "Set pam_pwquality.so password control in $pam_password for $::operatingsystem" => {
              service   => $pam_password,
              type      => 'password',
              control   => ['requisite'],
              module    => 'pam_pwquality.so',
              arguments => ['try_first_pass', 'local_users_only', 'retry=3', 'authtok_type='],
            },
          }
          if $manage_local_passwords {
            create_resources(cis::authentication::pam::apply, $pam_settings_for_rhel7)
          }
        }
        default : {
        }
      }
      $pam_settings = {
        #  CIS: Set Password Creation Requirement Parameters Using pam_cracklib
        #
        "Set pam_cracklib.so password control in $pam_password for $::operatingsystem" => {
          service   => $pam_password,
          type      => 'password',
          control   => ['required'],
          module    => 'pam_cracklib.so',
          arguments => ['retry=3', "minlen=${$pwquality_minlen}", "dcredit=${pwquality_dcredit}", "ucredit=${pwquality_ucredit}", "ocredit=${pwquality_ocredit}", "lcredit=${pwquality_lcredit}"],
        },

        # CIS Limit Password Reuse
        #
        "Set pam_unix.so password control in $pam_password for $::operatingsystem"     => {
          service   => $pam_password,
          type      => 'password',
          control   => ['sufficient'],
          module    => 'pam_unix.so',
          arguments => ['remember=5'],
          position  => 'after module pam_cracklib.so',
        },

        # CIS Restrict Access to the su Command
        #
        "Set pam_wheel.so auth control in su for $::operatingsystem"                   => {
          service   => "su",
          type      => 'auth',
          control   => ['required'],
          module    => 'pam_wheel.so',
          arguments => ['use_uid'],
        }
      }
    }
    'Debian', 'Ubuntu' : {
      $pam_password = 'common-password'
      $pam_auth     = 'common-auth'

      if ! defined(Package['libpam-cracklib']) {
        package { 'libpam-cracklib': ensure => installed, }
      }

      $pam_settings = {
        # CIS Set Lockout for Failed Password Attempts
        #
        "Set pam_tally2.so login control in login for $::operatingsystem"              => {
          service   => 'login',
          type      => 'auth',
          control   => ['required'],
          module    => 'pam_tally2.so',
          arguments => ['file=/var/log/tallylog', 'deny=3', 'even_deny_root', 'unlock_time=1200'],
          position  => 'before module pam_deny.so',
        },

        #  CIS: Set Password Creation Requirement Parameters Using pam_cracklib
        #
        "Set pam_cracklib.so password control in $pam_password for $::operatingsystem" => {
          service   => $pam_password,
          type      => 'password',
          control   => ['required'],
          module    => 'pam_cracklib.so',
          arguments => ['retry=3', "minlen=${$pwquality_minlen}", "dcredit=${pwquality_dcredit}", "ucredit=${pwquality_ucredit}", "ocredit=${pwquality_ocredit}", "lcredit=${pwquality_lcredit}"],
        },

        # CIS Limit Password Reuse
        #
        "Set pam_unix.so password control in $pam_password for $::operatingsystem"     => {
          service   => $pam_password,
          type      => 'password',
          control   => ['success=1', 'default=ignore'],
          module    => 'pam_unix.so',
          arguments => ['obscure', 'sha512', 'remember=5'],
          position  => 'after module pam_cracklib.so',
        },

        # CIS Restrict Access to the su Command
        #
        "Set pam_wheel.so auth control in su for $::operatingsystem"                   => {
          service   => "su",
          type      => 'auth',
          control   => ['required'],
          module    => 'pam_wheel.so',
          arguments => ['use_uid'],
        }
      }
    }
  }

  $pam_files = [$pam_password, $pam_auth, 'su', 'login']
  cis::authentication::pam::file { $pam_files: }

  if $manage_local_passwords {
    create_resources(cis::authentication::pam::apply, $pam_settings)
  }
}

# Apply CIS scored becnhmarks for Pam
#
define cis::authentication::pam::apply (
  $ensure    = 'present',
  $service   = undef,
  $type      = undef,
  $control   = undef,
  $module    = undef,
  $arguments = undef,
  $position  = undef
) {
  if ! defined(Pam["${name}"]) {
    pam { "${name}":
      ensure    => $ensure,
      service   => $service,
      type      => $type,
      control   => [$control],
      module    => $module,
      arguments => [$arguments],
      position  => $position
    }
  }
}

# Set ownership/permissions on pam.d files
#
define cis::authentication::pam::file {
  if ! defined(File["/etc/pam.d/${name}"]) {
    file { "/etc/pam.d/${name}":
      ensure => present,
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
    }
  }
}

# Affect changes to /etc/security/pwquality.conf on RHEL-based systems
#
define cis::authentication::pam::pwquality (
  $ensure   = 'present',
  $path     = '/etc/security/pwquality.conf',
  $setting,
  $value,
) {
  if ! defined(Ini_setting["${name}"]) {
    ini_setting { "${name}":
      ensure  => $ensure,
      path    => $path,
      setting => $setting,
      value   => $value,
    }
  }
}
