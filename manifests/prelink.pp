class cis::prelink {
  # CIS Disable Prelink
  # NOTE: RHEL 6 enables prelinking by default, while other distributions do not. RHEL 7 does not.
  # See: https://linux.web.cern.ch/linux/rhel/releasenotes/RELEASE-NOTES-7.0-x86_64/#removed-packages
  # Additionally, there's a scored CIS benchmark to *remove* prelink from Debian/Ubuntu systems
  #
  Exec { path            => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'] }

  case $::facts['os']['family'] {
    'OracleLinux', 'RedHat', 'CentOS', 'Fedora', 'Amazon' : {
      $prelink_defaults  = '/etc/sysconfig/prelink'
      $prelink_installed = '/bin/rpm -qa | /bin/grep -i prelink'
      $prelink_enabled   = "/bin/grep -i PRELINKING=yes ${prelink_defaults} > /dev/null 2>&1"
      case $::operatingsystemmajrelease {
        '6' : {
          exec { "sed -i 's/PRELINKING=yes/PRELINKING=no/g' ${prelink_defaults}":
            refreshonly  => true,
            user         => 'root',
            onlyif       => "${prelink_enabled}",
            subscribe    => Exec['prelink -ua'],
          }
        }
      }
    }
    'Debian', 'Ubuntu'           : {
      $prelink_defaults  = '/etc/default/prelink'
      $prelink_installed = '/usr/bin/dpkg --get-selections | /bin/grep -i prelink'
      $prelink_enabled   = "/bin/grep -iq PRELINKING=yes ${prelink_defaults}"
      # Remove prelink package for Debian/Ubuntu systems
      exec { 'apt-get -y purge prelink execstack libelfg0':
        onlyif    => "${prelink_installed}",
        subscribe => Exec['prelink -ua'],
      }
    }
  }

  exec { 'prelink -ua':
    onlyif  => "${prelink_installed} && ${prelink_enabled}",
    timeout => 0,
  }
}
