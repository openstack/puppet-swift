class swift::keystone::auth(
  $auth_name         = 'swift',
  $password          = 'swift_password',
  $address           = '127.0.0.1',
  $port              = '8080',
  $tenant            = 'services',
  $email             = 'swift@localhost',
  $region            = 'RegionOne',
  $public_protocol   = 'http',
  $public_address    = undef,
  $public_port       = undef,
  $admin_address     = undef,
  $internal_address  = undef
) {

if $address != '127.0.0.1' {
  warning('Address parameter for swift::keystone::auth has been deprecated, use public_address instead')
  }

  if ! $public_port {
    $real_public_port = $port
  } else {
    $real_public_port = $public_port
  }
  if ! $public_address {
    $real_public_address = $address
  } else {
    $real_public_address = $public_address
  }
  if ! $admin_address {
    $real_admin_address = $real_public_address
  } else {
    $real_admin_address = $admin_address
  }
  if ! $internal_address {
    $real_internal_address = $real_public_address
  } else {
    $real_internal_address = $internal_address
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
    public_url   => "${public_protocol}://${real_public_address}:${real_public_port}/v1/AUTH_%(tenant_id)s",
    admin_url    => "http://${real_admin_address}:${port}/",
    internal_url => "http://${real_internal_address}:${port}/v1/AUTH_%(tenant_id)s",
  }

  keystone_service { "${auth_name}_s3":
    ensure      => present,
    type        => 's3',
    description => 'Openstack S3 Service',
  }
  keystone_endpoint { "${region}/${auth_name}_s3":
    ensure       => present,
    public_url   => "${public_protocol}://${real_public_address}:${real_public_port}",
    admin_url    => "http://${real_admin_address}:${port}",
    internal_url => "http://${real_internal_address}:${port}",
  }

}
