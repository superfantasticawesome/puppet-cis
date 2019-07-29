class cis::ntp {
  if $::ec2_metadata != '' {
    $default_ntp_servers = [
      '0.amazon.pool.ntp.org',
      '1.amazon.pool.ntp.org',
      '2.amazon.pool.ntp.org',
      '3.amazon.pool.ntp.org'
    ]
  } else {
    $default_ntp_servers = [
      '0.us.pool.ntp.org',
      '1.us.pool.ntp.org',
      '2.us.pool.ntp.org',
      '3.us.pool.ntp.org'
    ]
  }
  $ntp_servers = lookup('cis::ntp_servers', $default_ntp_servers)

  if ! defined(Class['::ntp']) {
    class { '::ntp':
      package_ensure => installed,
      servers        => $ntp_servers,
      restrict       => [
        'restrict default kod nomodify notrap nopeer noquery',
        'restrict -6 default kod nomodify notrap nopeer noquery',
        'default ignore',
        '-6 default ignore',
        '127.0.0.1',
        '-6 ::1',
      ],
    }
  }
}
