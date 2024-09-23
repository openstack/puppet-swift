# == Class: swift::keystone::auth
#
# This class creates keystone users, services, endpoints, and roles
# for swift services.
#
# The user is given the admin role in the services tenant.
#
# === Parameters:
#
# [*password*]
#  String. The user's password.
#  Required.
#
# [*auth_name*]
#  String. The name of the user.
#  Optional. Defaults to 'swift'.
#
# [*tenant*]
#   (Optional) The tenant to use for the swift service user
#   Defaults to 'services'
#
# [*roles*]
#   (Optional) List of roles assigned to swift user.
#   Defaults to ['admin']
#
# [*system_scope*]
#   (Optional) Scope for system operations.
#   Defaults to 'all'
#
# [*system_roles*]
#   (Optional) List of system roles assigned to swift user.
#   Defaults to []
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
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'object-store'.
#
# [*service_type_s3*]
#   (Optional) Type of s3 service.
#   Defaults to 's3'.
#
# [*service_description*]
#   (optional) Description for keystone service.
#   Defaults to 'OpenStack Object-Store Service'.
#
# [*service_description_s3*]
#   (optional) Description for keystone s3 service.
#   Defaults to 'OpenStack S3 Service'.
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
  String[1] $password,
  String[1] $auth_name                       = 'swift',
  String[1] $tenant                          = 'services',
  Array[String[1]] $roles                    = ['admin'],
  String[1] $system_scope                    = 'all',
  Array[String[1]]$system_roles              = [],
  String[1] $email                           = 'swift@localhost',
  String[1] $region                          = 'RegionOne',
  Array[String[1]] $operator_roles           = ['admin', 'SwiftOperator'],
  String[1] $service_name                    = 'swift',
  String[1] $service_name_s3                 = 'swift_s3',
  String[1] $service_type                    = 'object-store',
  String[1] $service_type_s3                 = 's3',
  String[1] $service_description             = 'OpenStack Object-Store Service',
  String[1] $service_description_s3          = 'OpenStack S3 Service',
  Boolean $configure_endpoint                = true,
  Boolean $configure_s3_endpoint             = true,
  Boolean $configure_user                    = true,
  Boolean $configure_user_role               = true,
  Keystone::PublicEndpointUrl $public_url    = 'http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s',
  Keystone::EndpointUrl $admin_url           = 'http://127.0.0.1:8080',
  Keystone::EndpointUrl $internal_url        = 'http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s',
  Keystone::PublicEndpointUrl $public_url_s3 = 'http://127.0.0.1:8080',
  Keystone::EndpointUrl $admin_url_s3        = 'http://127.0.0.1:8080',
  Keystone::EndpointUrl $internal_url_s3     = 'http://127.0.0.1:8080',
) {

  include swift::deps

  if $service_name == $service_name_s3 {
    fail('swift::keystone::auth parameters service_name and service_name_s3 must be different.')
  }

  Keystone::Resource::Service_identity['swift'] -> Anchor['swift::service::end']
  Keystone::Resource::Service_identity['swift_s3'] -> Anchor['swift::service::end']

  keystone::resource::service_identity { 'swift':
    configure_endpoint  => $configure_endpoint,
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    service_name        => $service_name,
    service_type        => $service_type,
    service_description => $service_description,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    roles               => $roles,
    system_scope        => $system_scope,
    system_roles        => $system_roles,
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
    service_type        => $service_type_s3,
    service_description => $service_description_s3,
    region              => $region,
    public_url          => $public_url_s3,
    admin_url           => $admin_url_s3,
    internal_url        => $internal_url_s3,
  }

  if !empty($operator_roles) {
    #Roles like "admin" may be defined elsewhere, so use ensure_resource
    ensure_resource('keystone_role', $operator_roles, { 'ensure' => 'present' })
  }
}
