# class cis::auditd
class cis::auditd {
  include ::auditd

  # Ensure octal permissions on /var/log/audit
  file { '/var/log/audit':
    ensure  => directory,
    mode    => '0700',
  }

  case $::operatingsystem {
    'OracleLinux', 'RedHat', 'CentOS', 'Fedora', 'Amazon' : {
      $network_file = '/etc/sysconfig/network'
    }
    'Debian', 'Ubuntu' : {
      $network_file = '/etc/network'
    }
    default                      : {
      # Included for AWS Linux, which is based on RHEL 5/6
      $network_file = '/etc/sysconfig/network'
    }
  }

  $auditd_rules = {
    # CIS Record Events That Modify Date and Time Information
    #
    'Watch for access to get/set time x64' => {
      content => "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change",
      order   => '1',
    },
    'Watch for access to get/set time x32' => {
      content => "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -k time-change",
      order   => '2',
    },
    'Watch for access to clock and time functions x64' => {
      content => "-a always,exit -F arch=b64 -S clock_settime -k time-change",
      order   => '3',
    },
    'Watch for access to clock and time functions x32' => {
      content => "-a always,exit -F arch=b32 -S clock_settime -k time-change",
      order   => '4',
    },
    'Watch for acsess to localtime' => {
      content => '-w /etc/localtime -p wa -k time-change',
      order   => '5',
    },

    # CIS Record Events That Modify User/Group Information
    #
    'Watch for changes to group file' => {
      content => '-w /etc/group -p wa -k identity',
      order   => '6',
    },
    'Watch for changes to passwd file' => {
      content => '-w /etc/passwd -p wa -k identity',
      order   => '7',
    },
    'Watch for changes to gshadow file' => {
      content => '-w /etc/gshadow -p wa -k identity',
      order   => '8',
    },
    'Watch for changes to shadow file' => {
      content => '-w /etc/shadow -p wa -k identity',
      order   => '9',
    },
    'Watch for changes to opasswd file' => {
      content => '-w /etc/security/opasswd -p wa -k identity',
      order   => '10',
    },

    # CIS Record Events That Modify the System's Network Environment
    #
    'Watch for changes to hostname/domainname x64' => {
      content => "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale",
      order   => '11',
    },
    'Watch for changes to hostname/domainname x32' => {
      content => "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale",
      order   => '12',
    },
    'Watch for changes to issue file' => {
      content => '-w /etc/issue -p wa -k system-locale',
      order   => '13',
    },
    'Watch for changes to issue.net file' => {
      content => '-w /etc/issue.net -p wa -k system-locale',
      order   => '14',
    },
    'Watch for changes to hosts file' => {
      content => '-w /etc/hosts -p wa -k system-locale',
      order   => '15',
    },
    'Watch for changes to network file' => {
      content => "-w ${network_file} -p wa -k system-locale",
      order   => '16',
    },

    # CIS Record Events That Modify the System's Mandatory Access Controls
    #
    'Watch for changes to selinux directory' => {
      content => '-w /etc/selinux/ -p wa -k MAC-policy',
      order   => '17',
    },

    # CIS Collect Login and Logout Events
    #
    'Watch for changes to faillog file' => {
      content => '-w /var/log/faillog -p wa -k logins',
      order   => '18',
    },
    'Watch for changes to lastlog file' => {
      content => '-w /var/log/lastlog -p wa -k logins',
      order   => '19',
    },
    'Watch for changes to tallylog file' => {
      content => '-w /var/log/tallylog -p wa -k logins',
      order   => '20',
    },
    'Watch for changes to btmp file' => {
      content => '-w /var/log/btmp -p wa -k session',
      order   => '21',
    },

    # CIS Collect Session Initiation Information
    #
    'Watch for changes to utmp file' => {
      content => '-w /var/run/utmp -p wa -k session',
      order   => '22',
    },
    'Watch for changes to wtmp file' => {
      content => '-w /var/log/wtmp -p wa -k session',
      order   => '23',
    },

    # CIS Collect Discretionary Access Control Permission Modification Events
    #
    'Watch for changes implemented with chmod x64' => {
      content => "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod",
      order   => '24',
    },
    'Watch for changes implemented with chmod x32' => {
      content => "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod",
      order   => '25',
    },
    'Watch for changes implemented with chown x64' => {
      content => "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod",
      order   => '26',
    },
    'Watch for changes implemented with chown x32' => {
      content => "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod",
      order   => '27',
    },
    'Watch for changes implemented with setxattr x64' => {
      content => "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod",
      order   => '28',
    },
    'Watch for changes implemented with setxattr x32' => {
      content => "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod",
      order   => '29',
    },

    # CIS Collect Unsuccessful Unauthorized Access Attempts to Files
    #
    'Watch for permission denied errors x64' => {
      content => "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access",
      order   => '30',
    },
    'Watch for permission denied errors x32' => {
      content => "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access",
      order   => '31',
    },
    'Watch for other permanent errors x64' => {
      content => "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access",
      order   => '32',
    },
    'Watch for other permanent errors x32' => {
      content => "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access",
      order   => '33',
    },

    # CIS Collect Use of Privileged Commands
    #
    'Watch for use of cgexec command' => {
      content => '-a always,exit -F path=/bin/cgexec -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '34',
    },
    'Watch for use of mount command' => {
      content => '-a always,exit -F path=/bin/mount -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '35',
    },
    'Watch for use of umount command' => {
      content => '-a always,exit -F path=/bin/umount -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '36',
    },
    'Watch for use of ping command' => {
      content => '-a always,exit -F path=/bin/ping -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '37',
    },
    'Watch for use of su command' => {
      content => '-a always,exit -F path=/bin/su -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '38',
    },
    'Watch for use of ping6 command' => {
      content => '-a always,exit -F path=/bin/ping6 -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '39',
    },
    'Watch for use of unix_chkpwd command' => {
      content => '-a always,exit -F path=/sbin/unix_chkpwd -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '40',
    },
    'Watch for use of netreport command' => {
      content => '-a always,exit -F path=/sbin/netreport -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '41',
    },
    'Watch for use of pam_timestamp_check command' => {
      content => '-a always,exit -F path=/sbin/pam_timestamp_check -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged',
      order   => '42',
    },

    # CIS Collect Successful File System Mounts
    #
    'Watch for successful mounts x64' => {
      content => "-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts",
      order   => '43',
    },
    'Watch for successful mounts x32' => {
      content => "-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts",
      order   => '44',
    },

    # CIS Collect File Deletion Events by User
    #
    'Watch for file deletion events x64' => {
      content => "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete",
      order   => '45',
    },
    'Watch for file deletion events x32' => {
      content => "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete",
      order   => '46',
    },

    # CIS Collect Changes to System Administration Scope
    #
    'Watch for changes to sudoers file' => {
      content => '-w /etc/sudoers -p wa -k scope',
      order   => '47',
    },

    # CIS Collect System Administrator Actions
    #
    'Watch for changes to sudo.log file' => {
      content => '-w /var/log/sudo.log -p wa -k actions',
      order   => '48',
    },

    # CIS Collect Kernel Module Loading and Unloading
    #
    'Watch for kernel changes implemented with insmod' => {
      content => '-w /sbin/insmod -p x -k modules',
      order   => '49',
    },
    'Watch for kernel changes implemented with rmmod' => {
      content => '-w /sbin/rmmod -p x -k modules',
      order   => '50',
    },
    'Watch for kernel changes implemented with modprobe' => {
      content => '-w /sbin/modprobe -p x -k modules',
      order   => '51',
    },
    'Watch for kernel changes implemented with init_module x64' => {
      content => "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules",
      order   => '52',
    },
    'Watch for kernel changes implemented with init_module x32' => {
      content => "-a always,exit -F arch=b32 -S init_module -S delete_module -k modules",
      order   => '53',
    },

    # CIS Make the Audit Configuration Immutable
    #
    'Make auditd config file immutable' => {
      content => '-e 2',
      order   => '54',
    }
  }

  $auditd_rules.each |$description, $rules| {
    if 'x64' in "${description}" and ! '64' in $::facts['os']['architecture'] {
      notice("OS architecture ${::facts['os']['architecture']} doesn't support this rule")
    } else {
      # notify { "AUDITD: $description\n -> $rules": }
      ::auditd::rule { "${description}":
        content => $rules[content],
        order   => $rules[order],
      }
    }
  }
}
