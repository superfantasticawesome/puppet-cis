class cis::firewall::apply {
  # See https://forge.puppetlabs.com/puppetlabs/firewall for details
  #
  class { '::cis::firewall::pre': before    => Class['cis::firewall::rules'] }
  class { '::cis::firewall::rules': require => Class['cis::firewall::pre'], }
  class { '::cis::firewall::post': require  => Class['cis::firewall::rules'], }
}
