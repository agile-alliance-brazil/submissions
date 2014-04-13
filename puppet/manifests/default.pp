node default {
  exec { 'update':
      command => "apt-get update",
      path => "/usr/bin",
  }

  class { 'swap':
    swapsize => 5M,
  }

  $app_name = "submissions"
  $use_ssl = true

  class { 'web-server': }
  class { 'db-server': 
    app_name => $app_name,
  }

  $domain = "agilebrazil.com"
  $user = "ubuntu"
  class { 'rails-app':
    user => $user,
    app_name => $app_name,
    domain => $domain,
  }
}
