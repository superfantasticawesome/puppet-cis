class cis::firewall::pre {
  # See https://forge.puppetlabs.com/puppetlabs/firewall for details
  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }

  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
    require => Firewall['000 accept all icmp'],
  }

  firewall { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
    require     => Firewall['001 accept all to lo interface'],
  }

  firewall { '003 accept related established rules':
    proto   => 'all',
    state   => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
    require => Firewall['002 reject local traffic not on loopback interface']
  }
}
