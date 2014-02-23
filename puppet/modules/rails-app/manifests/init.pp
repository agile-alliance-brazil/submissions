class rails-app( $user, $app_name, $domain ) {
	package { "ruby1.9.3":
		ensure => "installed",
		require => Exec["update"],
	}

	exec { "update-gem-sources":
		command => "gem sources -u",
		path => "/usr/bin",
		require => Package["ruby1.9.3"],
	}

	package { "bundler":
		provider => "gem",
		ensure => "1.5.2",
		require => Exec["update-gem-sources"],
	}

	package { "puppet":
		provider => "gem",
		ensure => "3.4.2",
		require => Exec["update-gem-sources"],
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
	    source => "puppet:///modules/rails-app/self-signed.config",
	    require => File["/srv/apps/$app_name/shared"],
	  }

	  exec { "generate-certificate":
	    command => "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server_key.pem -out server.crt -config self-signed.config",
	    path => "/usr/bin/",
	    cwd => "/srv/apps/$app_name/shared/certs",
	    notify => Service['apache2'],
	    require => File['self-signed.config'],
	  }
	}

  # required for asset pipeline
	package { 'java':
		ensure => "installed",
		name => "openjdk-6-jre-headless",
		require => Exec["update"],
	}
}