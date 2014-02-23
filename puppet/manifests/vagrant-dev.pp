node default {
  exec { 'update':
      command => 'apt-get update',
      path => '/usr/bin',
  }

  package { 'git-core':
    ensure => 'present',
  }

  package { 'sqlite3':
    ensure => 'present',
  }

  package { 'libsqlite3-dev':
    ensure => 'present',
    require => Package['sqlite3'],
  }

  package { 'libmysql-ruby1.9.1': 
    ensure => 'present',
    require => Package['ruby1.9.3'],
  }

  #required for mysql2 gem
  package { 'libmysqlclient-dev':
    ensure => 'present',
  }

  $user = "vagrant"

  class { 'rails-app':
    user => $user,
    app_name => 'submissions',
    domain => 'agilebrazil.com',
  }

  class { 'swap':
    swapsize => 1M,
  }

  exec { 'bundle install':
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    command => 'bundle install --path vendor/bundle',
    cwd => '/srv/apps/submissions/current',
    user => $user,
    logoutput => true,
    require => [Class['rails-app'], Package['sqlite3'], Package['libmysql-ruby1.9.1'], Package['libmysqlclient-dev'], Package['git-core']]
  }

  package { 'xvfb':
    ensure => 'installed',
  }

  package { 'phantomjs':
    ensure => 'installed',
    require => Package['xvfb'],
  }
}
