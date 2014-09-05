node default {
  exec { 'update':
      command => "who",
      path => "/usr/bin",
  }

  class { 'swap':
    swapsize => 1M,
  }

  $app_name = "submissions"
  $domain = "agilebrazil.com"
  $use_ssl = true

  class { 'web-server':
    server_url => $server_url,
    rails_env => $rails_env,
  }
  class { 'db-server': 
    app_name => $app_name,
  }

  $user = "ubuntu"
  class { 'rails-app':
    user => $user,
    app_name => $app_name,
  }
}
