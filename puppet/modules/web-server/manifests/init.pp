class web-server($server_name = "$app_name.$domain") {
	include passenger-apache

	package { "git-core":
	  ensure => "present",
	}
	
	class { "rails-app::passenger":
		path => "/srv/apps/$app_name/current/public",
		server_name => $server_name,
	}
}