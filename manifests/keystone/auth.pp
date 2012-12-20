class swift::keystone::auth(
  $auth_name = 'swift',
  $password  = 'swift_password',
  $address   = '127.0.0.1',
  $port      = '8080',
  $tenant    = 'services',
  $email     = 'swift@localhost',
  $region    = 'RegionOne',
  $public_protocol = 'http',
  $public_port = undef
) {

  if ! $public_port {
	$real_public_port = $port
  } else {
	$real_public_port = $public_port
  }
  keystone_user { $auth_name:
    ensure   => present,
    password => $password,
    email    => $email,
    tenant   => $tenant,
  }
  keystone_user_role { "${auth_name}@${tenant}":
    ensure  => present,
    roles   => 'admin',
    require => Keystone_user[$auth_name]
  }

  keystone_service { $auth_name:
    ensure      => present,
    type        => 'object-store',
    description => 'Openstack Object-Store Service',
  }
  keystone_endpoint { "${region}/${auth_name}":
    ensure       => present,
    public_url   => "${public_protocol}://${address}:${real_public_port}/v1/AUTH_%(tenant_id)s",
    admin_url    => "http://${address}:${port}/",
    internal_url => "http://${address}:${port}/v1/AUTH_%(tenant_id)s",
  }

  keystone_service { "${auth_name}_s3":
    ensure      => present,
    type        => 's3',
    description => 'Openstack S3 Service',
  }
  keystone_endpoint { "${region}/${auth_name}_s3":
    ensure       => present,
    public_url   => "${public_protocol}://${address}:${real_public_port}",
    admin_url    => "http://${address}:${port}",
    internal_url => "http://${address}:${port}",
  }

}
