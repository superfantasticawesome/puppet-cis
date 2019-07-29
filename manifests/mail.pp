class cis::mail inherits cis::params {
  include postfix
  
  class { 'postfix::relay':
    sender_hostname    => $cis::params::sender_hostname,
    masquerade_domains => $cis::params::masquerade_domains,
    relayhost          => $cis::params::relayhost,
  }
}