class railsapp( $user, $app_name ) {
  class { '::rvm': }

  if $rvm_installed == true {
    rvm::system_user { $user:; }
    rvm_system_ruby { 'ruby-2.3.0':
        name        => 'ruby-2.3.0',
        ensure      => 'present',
        build_opts  => '--disable-binary',
        default_use => true
    }

    rvm_gem { 'bundler23':
        name         => 'bundler',
        ruby_version => 'ruby-2.3.0@global',
        ensure       => latest,
        require      => Rvm_system_ruby['ruby-2.3.0'];
    }

    rvm_system_ruby { 'ruby-2.3.1':
        name        => 'ruby-2.3.1',
        ensure      => 'present',
        build_opts  => '--disable-binary'
    }

    rvm_gem { 'bundler231':
        name         => 'bundler',
        ruby_version => 'ruby-2.3.1@global',
        ensure       => latest,
        require      => Rvm_system_ruby['ruby-2.3.1'];
    }
  }

  file { "/srv":
    ensure => "directory",
  }

  file { "/srv/apps":
    ensure => "directory",
    require => File["/srv"],
  }

  file { "/srv/apps/$app_name":
    ensure => "directory",
    owner => $user,
    require => File["/srv/apps"],
  }

  file { "/srv/apps/$app_name/shared":
    ensure => "directory",
    owner => $user,
    require => File["/srv/apps/$app_name"],
  }

  file { "config_folder":
    path => "/srv/apps/$app_name/shared/config",
    ensure => "directory",
    owner => $user,
    require => File["/srv/apps/$app_name/shared"],
  }

  file { "certs_folder":
    path => "/srv/apps/$app_name/shared/certs",
    ensure => "directory",
    owner => $user,
    require => File["/srv/apps/$app_name/shared"],
  }

  if $use_ssl {
    file { "self-signed.config":
      ensure => "present",
      path => "/srv/apps/$app_name/shared/certs/self-signed.config",
      source => "puppet:///modules/railsapp/self-signed.config",
      require => File["/srv/apps/$app_name/shared"],
    }

    exec { "generate-certificate":
      command => "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server_key.pem -out server.crt -config self-signed.config",
      path => "/usr/bin/",
      cwd => "/srv/apps/$app_name/shared/certs",
      notify => Service['apache2'],
      require => File['self-signed.config'],
      creates => "/srv/apps/$app_name/shared/certs/server.crt",
    }
  }

  # required for asset pipeline
  package { "java":
    ensure => "installed",
    name => "openjdk-6-jre-headless",
    require => Exec["update"],
  }

  # required for paperclip
  package { "imagemagick":
    ensure => "installed",
    require => Exec["update"]
  }
}
