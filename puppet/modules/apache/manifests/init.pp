class apache {
	package { "apache2":
		ensure => "installed",
		require => Exec["update"],
	}

	package { "apache2-prefork-dev":
		ensure => "installed",
		require => Exec["update"],
	}
	
	package { "libapr1-dev":
		ensure => "installed",
		require => Exec["update"],
	}
	
	package { "libaprutil1-dev":
		ensure => "installed",
		require => Exec["update"],
	}

	service { "apache2":
	  enable => true,
		ensure => running,
		hasrestart => true,
		hasstatus => true,
		require => [Package["apache2"], Package["apache2-prefork-dev"], Package["libapr1-dev"], Package["libaprutil1-dev"], Class["rails-app::passenger"]],
	}
}