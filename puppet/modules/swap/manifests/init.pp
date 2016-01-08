class swap( $ensure = 'present', $swapfile = '/swapfile', $swapsize = '1048576' ) {
  include stdlib

  $swapsizes = split("${swapsize}",'[.]')
  $swapfilesize = $swapsizes[0]

  file_line { "swap_fstab_line_${swapfile}":
    ensure => $ensure,
    line => "${swapfile} none swap sw 0 0",
    path => "/etc/fstab",
    match => "${swapfile}",
  }

  if $ensure == 'present' {
    exec { 'Create swap file':
      command => "/bin/dd if=/dev/zero of=${swapfile} bs=1024 count=${swapfilesize}",
      creates => $swapfile,
    }

    exec { 'Attach swap file':
      command => "/sbin/mkswap ${swapfile} && /sbin/swapon ${swapfile}",
      require => Exec['Create swap file'],
      unless => "/sbin/swapon -s | grep ${swapfile}",
    }
    file { $swapfile:
      owner => 'root',
      group => 'root',
      mode => '0600',
      require => Exec['Create swap file'],
     }
  } elsif $ensure == 'absent' {
    exec { 'Detach swap file':
      command => "/sbin/swapoff ${swapfile}",
      onlyif => "/sbin/swapon -s | grep ${swapfile}",
    }

    file { $swapfile:
      ensure => absent,
      require => Exec['Detach swap file'],
      backup => false,
    }
  }
}
