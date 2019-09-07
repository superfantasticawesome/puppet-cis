class cis::kernel inherits cis::params {
  # See: https://forge.puppetlabs.com/herculesteam/augeasproviders_sysctl
  #

  # CIS Configure ExecShield
  #
  case $::operatingsystem {
    'OracleLinux', 'RedHat', 'CentOS', 'Fedora', 'Amazon' : {
      case $::facts['os']['release']['major'] {
        '6' : {
          if ! 'uek' in $::facts['kernelrelease'] {
            if ! defined(Sysctl['kernel.exec-shield']) {
              sysctl { 'kernel.exec-shield':
                ensure => present,
                value  => '1',
              }
            }
          }
        }
        default : {
        }
      }

      if $::facts['os']['architecture'] != 'x86_64' and $::facts['os']['architecture'] != 'amd64' {
        if ! defined(Package['kernel-PAE']) {
          package { 'kernel-PAE': ensure => installed, }
        }
      }
    }
    default : {
    }
  }

  # CIS Disable Secure ICMP Redirect Acceptance
  #
  $accept_redirects = $cis::params::accept_redirects ? {
    'true'  => '1',
    default => '0',
  }

  # CIS Enable RFC-recommended Source Route Validation
  #
  $validate_route = $cis::params::validate_route ? {
    'true'  => '1',
    default => '0',
  }

  # CIS Disable Source Routed Packet Acceptance
  #
  $accept_source_route = $cis::params::accept_redirects ? {
    'true'  => '1',
    default => '0',
  }

  $sysctl_settings = {
    # CIS Restrict Core Dumps
    #
    'fs.suid_dumpable' => {
      value => '0',
    },

    # CIS Enable Randomized Virtual Memory
    # Region Placement
    #
    'kernel.randomize_va_space' => {
      value => '2',
    },

    # CIS Disable IP Forwarding
    #
    'net.ipv4.ip_forward' => {
      value => '0',
    },

    # CIS Disable IPv6 Router Advertisements
    #
    'net.ipv6.conf.all.accept_ra' => {
      value => '0',
    },

    # CIS Disable Send Packet Redirects
    #
    'net.ipv4.conf.all.send_redirects' => {
      value => '0',
    },

    'net.ipv4.conf.default.send_redirects' => {
      value => '0',
    },

    # CIS Disable ICMP Redirect Acceptance
    #
    'net.ipv4.conf.all.accept_redirects' => {
      value => '0',
    },

    # CIS Log Suspicious Packets
    #
    'net.ipv4.conf.all.log_martians' => {
      value => '1',
    },

    'net.ipv4.conf.default.log_martians' => {
      value => '1',
    },

    # CIS Enable Ignore Broadcast Requests
    #
    'net.ipv4.icmp_echo_ignore_broadcasts' => {
      value => '1',
    },

    # CIS Enable Bad Error Message Protection
    #
    'net.ipv4.icmp_ignore_bogus_error_responses' => {
      value => '1',
    },

    # CIS Enable TCP SYN Cookies
    #
    'net.ipv4.tcp_syncookies' => {
      value => '1',
    },

    'net.ipv4.conf.all.accept_source_route' => {
      value => $accept_source_route,
    },

    'net.ipv4.conf.all.secure_redirects' => {
      value => $accept_redirects,
    },

    'net.ipv4.conf.all.rp_filter' => {
      value => $validate_route,
    }
  }

  $sysctl_settings.each |String $setting, Hash $h| {
    sysctl { "${setting}":
      ensure => present,
      *      => $h,
    }
  }
}
