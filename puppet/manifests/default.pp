node default {
  include stdlib

  exec { 'update':
    command => "echo updated",
    path => "/bin",
  }

  class { 'swap':
    swapsize => to_bytes('1 MB'),
  }

  $app_name = "submissions"
  $domain = "agilebrazil.com"
  $use_ssl = true

  class { 'webserver':
    server_url => $server_url,
  }
  class { 'dbserver':
    app_name => $app_name,
  }

  $user = "ubuntu"
  class { 'railsapp':
    user => $user,
    app_name => $app_name,
  }
}
