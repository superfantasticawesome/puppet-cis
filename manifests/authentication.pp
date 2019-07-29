class cis::authentication {
  class { '::cis::authentication::banner': }
  class { '::cis::authentication::ssh': }
  class { '::cis::authentication::pam': }
  class { '::cis::authentication::shadow': }
}
