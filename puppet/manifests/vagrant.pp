exec { 'update':
  command => "apt-get update",
  path => "/usr/bin",
}

$app_name = "submissions"

class { 'swap':
  swapsize => 1M,
}

class { 'web-server':
  server_name => $server_url,
}
class { 'db-server': 
  app_name => $app_name
}

class { 'rails-app':
  user => "vagrant",
  app_name => $app_name,
}
