# == Class: swift::keystone::auth
#
# This class creates keystone users, services, endpoints, and roles
# for swift services.
#
# The user is given the admin role in the services tenant.
#
# === Parameters:
#
# [*auth_name*]
#  String. The name of the user.
#  Optional. Defaults to 'swift'.
#
# [*password*]
#  String. The user's password.
#  Optional. Defaults to 'swift_password'.
#
# [*port*]
#   (Optional) Port for endpoint.
#   Defaults to '8080'.
#
# [*public_port*]
#   (Optional) Port for endpoint.
#   Defaults to '8080'.
#
# [*tenant*]
#   (Optional) The tenant to use for the swift service user
#   Defaults to 'services'
#
# [*email*]
#   (Optional) The email address for the swift service user
#   Defaults to 'swift@localhost'
#
# [*region*]
#   (Optional) The region in which to place the endpoints
#   Defaults to 'RegionOne'
#
# [*operator_roles*]
#  (Optional) Array of strings. List of roles Swift considers as admin.
#  Defaults to '['admin', 'SwiftOperator']'
#
# [*public_protocol*]
#   (Optional) Protocol to use for the public endpoint. Can be http or https.
#   Defaults to 'http'
#
# [*public_address*]
#   (Optional) Public address for endpoint.
#   Defaults to '127.0.0.1'.
#
# [*admin_protocol*]
#   (Optional) Protocol for admin endpoints.
#   Defaults to 'http'.
#
# [*admin_address*]
#   (Optional) Admin address for endpoint.
#   Defaults to '127.0.0.1'.
#
# [*internal_protocol*]
#   Protocol for internal endpoints. Defaults to 'http'.
#
# [*internal_address*]
#   (Optional) Internal address for endpoint.
#   Defaults to '127.0.0.1'.
#
# [*configure_endpoint*]
#   (optional) Whether to create the endpoint.
#   Defaults to true
#
# [*configure_s3_endpoint*]
#   (optional) Whether to create the S3 endpoint.
#   Defaults to true
#
# [*endpoint_prefix*]
#   (optional) The prefix endpoint, used for endpoint URL.
#   Defaults to 'AUTH'
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of auth_name, but must differ from the value
#   of service_name_s3.
#
# [*service_name_s3*]
#   (optional) Name of the s3 service.
#   Defaults to the value of auth_name_s3, but must differ from the value
#   of service_name.
#
class swift::keystone::auth(
  $auth_name              = 'swift',
  $password               = 'swift_password',
  $port                   = '8080',
  $tenant                 = 'services',
  $email                  = 'swift@localhost',
  $region                 = 'RegionOne',
  $operator_roles         = ['admin', 'SwiftOperator'],
  $service_name           = undef,
  $service_name_s3        = undef,
  $public_protocol        = 'http',
  $public_address         = '127.0.0.1',
  $public_port            = undef,
  $admin_protocol         = 'http',
  $admin_address          = undef,
  $internal_protocol      = 'http',
  $internal_address       = undef,
  $configure_endpoint     = true,
  $configure_s3_endpoint  = true,
  $endpoint_prefix        = 'AUTH',
) {
  $real_service_name    = pick($service_name, $auth_name)
  $real_service_name_s3 = pick($service_name_s3, "${auth_name}_s3")

  if $real_service_name == $real_service_name_s3 {
      fail('cinder::keystone::auth parameters service_name and service_name_s3 must be different.')
  }

  if ! $public_port {
    $real_public_port = $port
  } else {
    $real_public_port = $public_port
  }
  if ! $admin_address {
    $real_admin_address = $public_address
  } else {
    $real_admin_address = $admin_address
  }
  if ! $internal_address {
    $real_internal_address = $public_address
  } else {
    $real_internal_address = $internal_address
  }

  keystone::resource::service_identity { 'swift':
    configure_endpoint  => $configure_endpoint,
    service_name        => $real_service_name,
    service_type        => 'object-store',
    service_description => 'Openstack Object-Store Service',
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => "${public_protocol}://${public_address}:${real_public_port}/v1/${endpoint_prefix}_%(tenant_id)s",
    admin_url           => "${admin_protocol}://${real_admin_address}:${port}/",
    internal_url        => "${internal_protocol}://${real_internal_address}:${port}/v1/${endpoint_prefix}_%(tenant_id)s",
  }

  keystone::resource::service_identity { 'swift_s3':
    configure_user      => false,
    configure_user_role => false,
    configure_endpoint  => $configure_s3_endpoint,
    configure_service   => $configure_s3_endpoint,
    service_name        => $real_service_name_s3,
    service_type        => 's3',
    service_description => 'Openstack S3 Service',
    region              => $region,
    public_url          => "${public_protocol}://${public_address}:${real_public_port}",
    admin_url           => "${admin_protocol}://${real_admin_address}:${port}",
    internal_url        => "${internal_protocol}://${real_internal_address}:${port}",
  }

  if $operator_roles {
    #Roles like "admin" may be defined elsewhere, so use ensure_resource
    ensure_resource('keystone_role', $operator_roles, { 'ensure' => 'present' })
  }

  # Backward compatibility
  Keystone_user[$auth_name] -> Keystone_user_role["${auth_name}@${tenant}"]

}
