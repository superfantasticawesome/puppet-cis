class cis::firewall::rules {
  # See https://forge.puppetlabs.com/puppetlabs/firewall for details
  # 
  # Your custom rules here
  firewall { '100 allow ssh':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '22',
    proto   => 'tcp',
    action  => 'accept',
  }  
}
