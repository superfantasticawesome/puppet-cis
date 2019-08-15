# class: cis::authentication::ssh
# NOTE: If having difficulty authenticating via password-based logins, e.g.,
#       'Received disconnect from <host>: Too many authentication failures for <username>'
#       Try "ssh -o PubkeyAuthentication=no username@hostname.com"
#
class cis::authentication::ssh inherits cis::params {

  # CIS Set Permissions on /etc/ssh/sshd_config
  #
  file { '/etc/ssh/sshd_config':
    owner => 'root',
    group => 'root',
    mode  => '0600',
  }

  # See: https://forge.puppetlabs.com/herculesteam/augeasproviders_ssh
  # Also see: http://augeasproviders.com/documentation/examples.html
  #

  $sshd_config = {
    # CIS Set SSH Protocol to 2
    #
    'Protocol' => {
      value => ['2'],
    },

    # CIS Set LogLevel to INFO
    #
    'LogLevel' => {
      value => ['INFO'],
    },

    # CIS Disable SSH X11 Forwarding
    #
    'X11Forwarding' => {
      value => ["${ssh_x11_forwarding}"],
    },

    # CIS Set SSH MaxAuthTries to 4 or Less
    #
    'MaxAuthTries' => {
      value => ['4'],
    },

    # CIS Set SSH HostbasedAuthentication to No
    #
    'HostbasedAuthentication' => {
      value => ["${hostbasedauthentication}"],
    },

    # CIS Disable SSH Root Login
    #
    'PermitRootLogin' => {
      value => ["${permit_root_login}"],
    },

    # CIS Set SSH PermitEmptyPasswords to No
    #
    'PermitEmptyPasswords' => {
      value => ['no'],
    },

    # CIS Do Not Allow Users to Set Environment Options
    #
    'PermitUserEnvironment' => {
      value => ['no'],
    },

    # CIS Use Only Approved Cipher in Counter Mode
    #
    'Ciphers' => {
      value => ['aes128-ctr', 'aes192-ctr', 'aes256-ctr'],
    },

    # CIS Set Idle Timeout Interval for User Login
    #
    'ClientAliveInterval' => {
      value => ['3600'],
    },

    'ClientAliveCountMax' => {
      value => ['0'],
    },

    # CIS Set SSH Banner
    #
    'Banner' => {
      value => ['/etc/issue.net'],
    }
  }
  
  $sshd_config.each |String $config, Hash $data| {
    sshd_config { "${config}":
      ensure => present,
      value  => $data['value'],
    }
  }
}
