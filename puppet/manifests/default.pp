node default {
  exec { 'update':
      command => "apt-get update",
      path => "/usr/bin",
  }

  class { 'swap':
    swapsize => 1M,
  }

  $app_name = "submissions"
  $domain = "agilebrazil.com"
  $use_ssl = true

  class { 'web-server':
    server_name => "$app_name.$domain",
  }
  class { 'db-server': 
    app_name => $app_name,
  }

  $user = "ubuntu"
  class { 'rails-app':
    user => $user,
    app_name => $app_name,
    domain => $domain,
  }
}
