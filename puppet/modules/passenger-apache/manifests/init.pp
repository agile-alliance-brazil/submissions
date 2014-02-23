class passenger-apache {
	include apache

	package { 'librack-ruby1.9.1': 
		ensure => "present",
		require => Package["ruby1.9.3"],
	}

  package { 'passenger':
    ensure => "4.0.37",
    provider => "gem",
    require => Package['librack-ruby1.9.1'],
	}

  package { "build-essential":
    ensure => "installed",
    require => Exec["update"],
  }

  package { 'libcurl4-openssl-dev':
    ensure => "installed",
    require => Exec["update"],
  }

  package { "libssl-dev":
    ensure => "installed",
    require => Exec["update"],
  }

  package { "zlib1g-dev":
    ensure => "installed",
    require => Exec["update"],
  }

  exec { "passenger-install-apache2-module":
    command => "passenger-install-apache2-module --languages ruby --auto",
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
    onlyif => "/usr/bin/test ! -f /var/lib/gems/1.9.1/gems/passenger-4.0.37/buildout/apache2/mod_passenger.so",
    user => 'root',
    require => [
      Package['passenger'], Package['build-essential'], Package['libcurl4-openssl-dev'],
      Package['libssl-dev'], Package['zlib1g-dev'], Package['apache2-prefork-dev'],
      Package['libapr1-dev'], Package['libaprutil1-dev'], Class['swap']
    ],
  }

  file { '/etc/apache2/mods-available/passenger.load':
    source => 'puppet:///modules/passenger-apache/passenger.load',
    require => Exec['passenger-install-apache2-module'],
  }

  file { '/etc/apache2/mods-available/passenger.conf':
    source => 'puppet:///modules/passenger-apache/passenger.conf',
    require => Exec['passenger-install-apache2-module'],
  }

  file { '/etc/apache2/mods-enabled/passenger.load':
    ensure => '/etc/apache2/mods-available/passenger.load',
    require => File['/etc/apache2/mods-available/passenger.load'],
    notify => Service['apache2'],
  }

  file { '/etc/apache2/mods-enabled/passenger.conf':
    ensure => '/etc/apache2/mods-available/passenger.conf',
    require => File['/etc/apache2/mods-available/passenger.conf'],
    notify => Service['apache2'],
  }
}