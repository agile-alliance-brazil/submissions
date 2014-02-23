class mysql {
	package { "mysql-server":
		ensure => "installed",
		require => Exec["update"],
	}

	package { "mysql-client":
		ensure => "installed",
		require => Exec["update"],
	}

	service { "mysql":
	    enable => true,
		ensure => running,
		hasrestart => true,
		hasstatus => true,
		require => [Package["mysql-server"], Package["mysql-client"]],
	}
}