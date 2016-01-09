class railsapp::passenger ($path = '/srv/apps/rails-app/current/public', $server_url) {
  class { 'apache': }
  
  if $rvm_installed == true {
    class { 'rvm::passenger::apache':
        version            => '4.0.37',
        ruby_version       => 'ruby-1.9.3-p551',
        mininstances       => '3',
        maxinstancesperapp => '0',
        maxpoolsize        => '30',
        spawnmethod        => 'smart-lv2'
    }
  }

  file { "/etc/apache2/sites-available/$server_url":
    ensure => 'present',
    content => template('railsapp/passenger-app.erb'),
    require => Package['httpd'],
    notify => Class['apache::service'],
  }

  file { "/etc/apache2/sites-enabled/000-default":
    ensure => "/etc/apache2/sites-available/$server_url",
    require => File["/etc/apache2/sites-available/$server_url"],
    notify => Class['apache::service'],
  }

  if $use_ssl {
    file { '/etc/apache2/mods-enabled/ssl.conf':
      ensure => 'link',
      target => '/etc/apache2/mods-available/ssl.conf',
      require => [Package['httpd'], File['/etc/apache2/mods-enabled/socache_shmcb.load']],
      notify => Class['apache::service'],
    }

    file { '/etc/apache2/mods-enabled/ssl.load':
      ensure => 'link',
      target => '/etc/apache2/mods-available/ssl.load',
      require => Package['httpd'],
      notify => Class['apache::service'],
    }

    file { '/etc/apache2/mods-enabled/socache_shmcb.load':
      ensure => 'link',
      target => '/etc/apache2/mods-available/socache_shmcb.load',
      require => Package['httpd'],
      notify => Class['apache::service'],
    }
  }
}