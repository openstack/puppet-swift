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
# [*configure_endpoint*]
#   (optional) Whether to create the endpoint.
#   Defaults to true
#
# [*configure_s3_endpoint*]
#   (optional) Whether to create the S3 endpoint.
#   Defaults to true
#
# [*configure_user*]
#   (Optional) Whether to create the service user.
#   Defaults to 'true'.
#
# [*configure_user_role*]
#   (Optional) Whether to configure the admin role for the service user.
#   Defaults to 'true'.
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to 'swift'
#
# [*service_name_s3*]
#   (optional) Name of the s3 service.
#   Defaults to 'swift_s3'
#
# [*service_description*]
#   (optional) Description for keystone service.
#   Defaults to 'Openstack Object-Store Service'.
#
# [*service_description_s3*]
#   (optional) Description for keystone s3 service.
#   Defaults to 'Openstack S3 Service'.
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8080')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*public_url_s3*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:8080')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url_s3*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8080')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url_s3*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8080')
#   This url should *not* contain any trailing '/'.
#
class swift::keystone::auth(
  $auth_name              = 'swift',
  $password               = 'swift_password',
  $tenant                 = 'services',
  $email                  = 'swift@localhost',
  $region                 = 'RegionOne',
  $operator_roles         = ['admin', 'SwiftOperator'],
  $service_name           = 'swift',
  $service_name_s3        = 'swift_s3',
  $service_description    = 'Openstack Object-Store Service',
  $service_description_s3 = 'Openstack S3 Service',
  $configure_endpoint     = true,
  $configure_s3_endpoint  = true,
  $configure_user         = true,
  $configure_user_role    = true,
  $public_url             = 'http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s',
  $admin_url              = 'http://127.0.0.1:8080',
  $internal_url           = 'http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s',
  $public_url_s3          = 'http://127.0.0.1:8080',
  $admin_url_s3           = 'http://127.0.0.1:8080',
  $internal_url_s3        = 'http://127.0.0.1:8080',
) {

  include ::swift::deps

  if $service_name == $service_name_s3 {
      fail('swift::keystone::auth parameters service_name and service_name_s3 must be different.')
  }

  # Establish that keystone auth and endpoints are properly setup before
  # managing any type of swift related service.
  if $configure_endpoint {
    Keystone_endpoint["${region}/${service_name}::object-store"] -> Swift::Service<||>
  }
  if $configure_s3_endpoint {
    Keystone_endpoint["${region}/${service_name_s3}::s3"] -> Swift::Service<||>
  }

  keystone::resource::service_identity { 'swift':
    configure_endpoint  => $configure_endpoint,
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    service_name        => $service_name,
    service_type        => 'object-store',
    service_description => $service_description,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }

  keystone::resource::service_identity { 'swift_s3':
    configure_user      => false,
    configure_user_role => false,
    configure_endpoint  => $configure_s3_endpoint,
    configure_service   => $configure_s3_endpoint,
    service_name        => $service_name_s3,
    service_type        => 's3',
    service_description => $service_description_s3,
    region              => $region,
    public_url          => $public_url_s3,
    admin_url           => $admin_url_s3,
    internal_url        => $internal_url_s3,
  }

  if $operator_roles {
    #Roles like "admin" may be defined elsewhere, so use ensure_resource
    ensure_resource('keystone_role', $operator_roles, { 'ensure' => 'present' })
  }

  # Backward compatibility
  if $configure_user {
    Keystone_user[$auth_name] -> Keystone_user_role["${auth_name}@${tenant}"]
  }

}
