class cis::hosts {
  # CIS Verify Permissions on /etc/hosts.allow and /etc/hosts.deny
  file { [ '/etc/hosts.deny', '/etc/hosts.allow' ]:
    ensure => present,
    mode   => '0644',
    owner  => root,
  }
}
