# == Class cis::params
#
# - Roles and profiles dictate core services configuration
# - NTP managed by ntp module
# - Firewall managed by firewall module
# - The auditd configuration managed by auditd module
#
# TODO: Add more configuration options to Hiera
class cis::params {
  # General options. These can be overridden with Hiera.
  $general_options = {
    name => 'cis_options',
    default_value => {
      ban_exceptions         => undef,
      service_exceptions     => undef,
      nat_instance           => false,
      secure_grub            => false,
      manage_aide            => true,
      manage_local_firewall  => false,
      manage_local_passwords => false,
      manage_motd            => true,
      manage_ntp             => false,
      manage_selinux         => true,
      selinux_mode           => 'enforcing'
    }
  }
  $search_options = { value_type => Hash, merge => 'first' }
  $cis_options = lookup($search_options + $general_options)

  $ban_exceptions         = $cis_options[ban_exceptions]
  $service_exceptions     = $cis_options[service_exceptions]
  $nat_instance           = $cis_options[nat_instance]
  $secure_grub            = $cis_options[secure_grub]
  $manage_aide            = $cis_options[manage_aide]
  $manage_local_firewall  = $cis_options[manage_local_firewall]
  $manage_local_passwords = $cis_options[manage_local_passwords]
  $manage_motd            = $cis_options[manage_motd]
  $manage_ntp             = $cis_options[manage_ntp]
  $manage_selinux         = $cis_options[manage_selinux]
  $selinux_mode           = $cis_options[selinux_mode]

  # authentication/shadow.pp
  $pasword_max_days  = '90'
  $password_min_days = '7'
  $password_warn_age = '7'
  # authentication/pam.pp
  $pwquality_minlen  = '14'
  $pwquality_dcredit = '-1'
  $pwquality_ucredit = '-1'
  $pwquality_ocredit = '-1'
  $pwquality_lcredit = '-1'
  # kernel.pp
  $accept_all_src_routes = false
  $accept_redirects      = false
  $validate_route        = false
  # mail.pp
  $sender_hostname    = 'sender.example.org'
  $masquerade_domains = 'example.org'
  $relayhost          = 'receiver.example.org'
  # authentication/ssh.pp
  $ssh_x11_forwarding      = 'yes'
  $permit_root_login       = 'no'
  $hostbasedauthentication = 'yes'
  $banner = ' *********************************** WARNING ***********************************
 You have accessed a private computer system. This system is for authorized use
 only and user activities may be monitored and recorded by company personnel.
 Unauthorized access to or use of this system is strictly prohibited and
 constitutes a violation of federal, criminal, and civil laws. Violators may
 be subject to employment termination and prosecuted to the fullest extent of
 the law. By logging in you certify that you have read and understood these
 terms and that you are authorized to access and use the system.
 *********************************** WARNING ***********************************
'
  case $::operatingsystem {
    'OracleLinux', 'RedHat', 'CentOS', 'Fedora', 'Amazon' : {
      $umask_daemon = '027'
      $umask_user   = '077'
      $ssh_daemon   = 'sshd'
      $http_daemon  = 'httpd'
      $packages     = ['cronie-anacron', 'tcp_wrappers']
      $services     = ['crond', $ssh_daemon]
      $disabled_services = [
        'rhnsd',
        'chargen-dgram',
        'chargen-stream',
        'daytime-stream',
        'daytime-dgram',
        'echo-dgram',
        'echo-stream',
        'tcpmux-server',
        'avahi-daemon',
        'cups',
        'autofs',
        'rpcsvgssd',
        'rpcgssd',
        'rpcbind',
        'rpcidmapd',
        'nfslock',
      ]
      $ban_all_ = [
        'dovecot',
        'squid',
        'setroubleshoot',
        'mctrans',
        'telnet-server',
        'telnet',
        'rsh-server',
        'rsh',
        'net-snmp',
        'ypserv',
        'ypbind',
        'tftp',
        'tftp-server',
        'talk',
        'talk-server',
        'xinetd',
        'xorg-x11-server-common',
        'dhcp',
        'openldap-servers',
        'openldap-clients',
        'bind',
        'vsftpd',
        'httpd',
        'samba',
      ]
      # Handle os/release specific package dependencies
      #
      case $::operatingsystemmajrelease {
        '6' : {
          $ban_all = $ban_all_ + ['yp_tools']
        }
        '7' : {
          $ban_all = $ban_all_ + ['mod_dav_svn']
        }
        default : {
        }
      }
    }
    'Debian', 'Ubuntu' : {
      $umask_inactive    = '035'
      $umask_user        = '077'
      $ssh_daemon        = 'ssh'
      $http_daemon       = 'apache2'
      $service_base      = ['cron', $ssh_daemon, 'apparmor']
      $packages          = ['tcpd', 'apparmor-utils', 'apparmor-profiles']
      $disabled_services = ['rsync',]
      # Prelink is now managed in cis::prelink
      $ban_all = [
        'apport',
        'vsftpd',
        'discard',
        'bind9',
        'xinetd',
        'smbd',
        'apache2',
        'tftp',
        'avahi-daemon',
        'daytime',
        'echo',
        'whoopsie',
        'time',
        'telnet',
        'rpc',
        'nfs-kernel-server',
        'autofs',
        'isc-dhcp-server',
        'isc-dhcp-server6',
        'xserver-xorg-core*',
        'slapd',
        'dovecot',
        'biosdevname',
        'snmpd',
        'nis',
        'chargen',
        'rsh-client',
        'atftp',
        'rsh-reload-client',
        'talk',
        'ntalk',
        'nfs',
        'squid3',
        'cups',
        'telnet-server',
      ]
    }
    default : {
    }
  }
  if $service_exceptions != undef {
    warning("Ignoring scored benchmarks to enable the following exceptions: ${service_exceptions}")
    $disabled = $disabled_services - $service_exceptions
  } else {
    $disabled = $disabled_services
  }
  if $ban_exceptions != undef {
    if $manage_local_firewall {
      warning("The local firewall service is enabled with ban exceptions. Ensure that appropriate firewall rules are configured.")
    }
    $banned = $ban_all - $ban_exceptions
  } else {
    $banned = $ban_all
  }
}
