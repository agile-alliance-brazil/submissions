define railsapp::mysqldb( $user, $password ) {
  exec { "create-${name}-db":
    unless => "/usr/bin/mysql -uroot ${name}",
    command => "/usr/bin/mysql -uroot -e \"create database ${name};\"",
    require => Service["mysql"],
  }

  exec { "grant-${name}-db":
    unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
    command => "/usr/bin/mysql -uroot -e \"grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
    require => [Service["mysql"], Exec["create-${name}-db"]]
  }
}

class railsapp::db ($app_name = 'rails-app', $password) {
  railsapp::mysqldb { "myapp":
  	name => "${app_name}_production",
    user => "${app_name}_db",
    password => $password,
  }
}