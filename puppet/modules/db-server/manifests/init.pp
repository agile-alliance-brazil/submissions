class db-server ($app_name = 'rails-app') {
	include mysql

	package { 'libmysql-ruby1.9.1': 
		require => Package['ruby1.9.3'],
	}
	
	class { "rails-app::db":
		app_name => "$app_name",
		password => "SuperSecret",
	}
}