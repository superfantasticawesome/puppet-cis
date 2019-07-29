# class cis::authentication::banner
#
class cis::authentication::banner inherits cis::params {
  if $cis::params::manage_motd {
    file { ['/etc/issue.net', '/etc/motd']:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content  => $banner,
    }
  }
}
