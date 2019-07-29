class cis::firewall::post {
  # See https://forge.puppetlabs.com/puppetlabs/firewall for details
  #
  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}
