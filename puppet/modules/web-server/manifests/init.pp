class web-server($app_name = "submissions", $server_url = "$app_name.$domain") {
	include passenger-apache

	package { "git-core":
	  ensure => "present",
	}
	
	class { "rails-app::passenger":
		path => "/srv/apps/$app_name/current/public",
		server_url => $server_url,
	}
}