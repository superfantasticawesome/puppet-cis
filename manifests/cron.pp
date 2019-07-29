# class cis::cron
class cis::cron {
  require cis::services

  # CIS Restrict at/cron to Authorized Users
  #
  file { [ '/etc/cron.hourly', '/etc/cron.daily', '/etc/cron.weekly', '/etc/cron.monthly', '/etc/cron.d' ]:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0770',
    recurse => true,
  }

  file { [ '/etc/crontab', '/etc/cron.allow', '/etc/at.allow' ]:
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0770',
  }

  file { [ '/etc/cron.deny', '/etc/at.deny' ]:
    ensure => 'absent',
  }
}
