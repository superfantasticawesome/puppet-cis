class cis::grub {
  require ::cis::auditd

  $grub_secret   = lookup('grub_encrypted')
  $grub_password = lookup('grub_clear')

  # Correct all kernel lines to have the needed console parameters
  augeas { 'grub-set-kernel-consoles':
    context => '/files/boot/grub/menu.lst',
    changes => ['set /files/boot/grub/menu.lst/title/kernel/ audit=1'],
  }
  if ! $grub_secret.empty && ! $grub_password.empty {
    augeas { 'Add SHA-512 password to Grub':
      context => "/files/boot/grub/menu.lst",
      changes => ['ins password after timeout', "${grub_secret}", "${grub_password}"],
      onlyif  => "match password size == 0";
    }
  }
}
