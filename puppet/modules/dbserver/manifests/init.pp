class dbserver ($app_name = 'rails-app') {
	include mysql
	
	class { "railsapp::db":
		app_name => "$app_name",
		password => "53cr3T",
	}
}