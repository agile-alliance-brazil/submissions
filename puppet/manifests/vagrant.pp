node default {
  include stdlib

  exec { 'update':
    command => "apt-get update",
    path => "/usr/bin",
  }

  $app_name = "submissions"

  class { 'swap':
    swapsize => to_bytes('1 MB'),
  }

  class { 'web-server':
    server_url => $server_url,
  }
  class { 'db-server':
    app_name => $app_name
  }

  class { 'rails-app':
    user => "vagrant",
    app_name => $app_name,
    rails_env => $rails_env,
  }
}
