# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include cis
#
class cis (
  # general options
  $service_exceptions      = $cis::params::service_exceptions,
  $ban_exceptions          = $cis::params::ban_exceptions,
  $nat_instance            = $cis::params::nat_instance,
  $secure_grub             = $cis::params::secure_grub,
  $manage_aide             = $cis::params::manage_aide,
  $manage_local_firewall   = $cis::params::manage_local_firewall,
  $manage_local_passwords  = $cis::params::manage_local_passwords,
  $manage_motd             = $cis::params::manage_motd,
  $manage_ntp              = $cis::params::manage_ntp,
  $manage_selinux          = $cis::params::manage_selinux,
  $selinux_mode            = $cis::params::selinux_mode,
  # authentication/shadow.pp
  $pasword_max_days        = $cis::params::pasword_max_days,
  $password_min_days       = $cis::params::password_min_days,
  $password_warn_age       = $cis::params::password_warn_age,
  # authentication/pam.pp
  $pwquality_minlen        = $cis::params::pwquality_minlen,
  $pwquality_dcredit       = $cis::params::pwquality_dcredit,
  $pwquality_ucredit       = $cis::params::pwquality_ucredit,
  $pwquality_ocredit       = $cis::params::pwquality_ocredit,
  $pwquality_lcredit       = $cis::params::pwquality_lcredit,
  # kernel.pp
  $accept_all_src_routes   = $cis::params::accept_all_src_routes,
  $accept_redirects        = $cis::params::accept_redirects,
  $validate_route          = $cis::params::validate_route,
  # mail.pp
  $sender_hostname         = $cis::params::sender_hostname,
  $masquerade_domains      = $cis::params::masquerade_domains,
  $relayhost               = $cis::params::relayhost,
  # authentication/ssh.pp
  $ssh_x11_forwarding      = $cis::params::ssh_x11_forwarding,
  $permit_root_login       = $cis::params::permit_root_login,
  $hostbasedauthentication = $cis::params::hostbasedauthentication
) inherits cis::params {
  if $manage_selinux {
    class { selinux: mode => $selinux_mode }
  }

  if $secure_grub {
    class { '::cis::grub': }
  }

  if ! $nat_instance {
    class { '::cis::kernel': }
  }

  if $manage_local_firewall {
    class { '::cis::firewall::apply': }
  }

  if $manage_ntp {
    class { '::cis::ntp': }
  }
  
  if $manage_aide {
    class { '::cis::aide': }
  }
  
  class { '::cis::prelink': }
  class { '::cis::packages': }
  class { '::cis::services': }
  class { '::cis::banned': }
  class { '::cis::cron': }
  class { '::cis::auditd': }
  class { '::cis::hosts': }
  class { '::cis::authentication': }
}
