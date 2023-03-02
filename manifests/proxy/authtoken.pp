#
# This class can be used to manage keystone's authtoken middleware
# for swift proxy
#
# == Parameters
#
# [*delay_auth_decision*]
#   (Optional) Do not handle authorization requests within the middleware, but
#   delegate the authorization decision to downstream WSGI components. Boolean value
#   Defaults to 1
#
# [*cache*]
#    The cache backend to use
#    Optional. Defaults to 'swift.cache'
#
# [*www_authenticate_uri*]
#   (Optional) Complete public Identity API endpoint.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*auth_url*]
#   (Optional) The URL to use for authentication.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*auth_type*]
#   (Optional) The plugin for authentication
#   Defaults to 'password'
#
# [*username*]
#   (Optional) The name of the service user
#   Defaults to 'swift'
#
# [*user_domain_id*]
#   (Optional) id of domain for $username
#   Defaults to 'default'
#
# [*password*]
#   (Optional) The password for the user
#   Defaults to 'password'
#
# [*project_name*]
#   (Optional) Service project name
#   Defaults to 'services'
#
# [*project_domain_id*]
#   (Optional) id of domain for $project_name
#   Defaults to 'default'
#
# [*system_scope*]
#   (Optional) Scope for system operations
#   Defaults to $facts['os_service_default']
#
# [*region_name*]
#   (Optional) The region in which the identity server can be found.
#   Defaults to $facts['os_service_default'].
#
# [*include_service_catalog*]
#   (Optional) Indicate whether to set the X-Service-Catalog header. If False,
#   middleware will not ask for service catalog on token validation and will
#   not set the X-Service-Catalog header. Boolean value.
#   Defaults to false
#
# [*service_token_roles*]
#  (Optional) A choice of roles that must be present in a service token.
#  Service tokens are allowed to request that an expired token
#  can be used and so this check should tightly control that
#  only actual services should be sending this token. Roles
#  here are applied as an ANY check so any role in this list
#  must be present. For backwards compatibility reasons this
#  currently only affects the allow_expired check. (list value)
#  Defaults to $facts['os_service_default'].
#
# [*service_token_roles_required*]
#  (optional) backwards compatibility to ensure that the service tokens are
#  compared against a list of possible roles for validity
#  true/false
#  Defaults to $facts['os_service_default'].
#
# [*service_type*]
#  (Optional) The name or type of the service as it appears in the service
#  catalog. This is used to validate tokens that have restricted access rules.
#  Defaults to $facts['os_service_default'].
#
# [*interface*]
#  (Optional) Interface to use for the Identity API endpoint. Valid values are
#  "public", "internal" or "admin".
#  Defaults to $facts['os_service_default'].
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class swift::proxy::authtoken(
  $delay_auth_decision          = 1,
  $cache                        = 'swift.cache',
  $www_authenticate_uri         = 'http://127.0.0.1:5000',
  $auth_url                     = 'http://127.0.0.1:5000',
  $auth_type                    = 'password',
  $username                     = 'swift',
  $user_domain_id               = 'default',
  $password                     = undef,
  $project_name                 = 'services',
  $project_domain_id            = 'default',
  $system_scope                 = $facts['os_service_default'],
  $region_name                  = $facts['os_service_default'],
  $include_service_catalog      = false,
  $service_token_roles          = $facts['os_service_default'],
  $service_token_roles_required = $facts['os_service_default'],
  $service_type                 = $facts['os_service_default'],
  $interface                    = $facts['os_service_default'],
) inherits swift::params {

  include swift::deps

  if $password == undef {
    warning('Usage of the default password is deprecated and will be removed in a future release. \
Please set password parameter')
    $password_real = 'password'
  } else {
    $password_real = $password
  }

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_id_real = $project_domain_id
  } else {
    $project_name_real = $facts['os_service_default']
    $project_domain_id_real = $facts['os_service_default']
  }

  swift_proxy_config {
    'filter:authtoken/log_name':                     value => 'swift';
    'filter:authtoken/paste.filter_factory':         value => 'keystonemiddleware.auth_token:filter_factory';
    'filter:authtoken/www_authenticate_uri':         value => $www_authenticate_uri;
    'filter:authtoken/auth_url':                     value => $auth_url;
    'filter:authtoken/auth_type':                    value => $auth_type;
    'filter:authtoken/username':                     value => $username;
    'filter:authtoken/user_domain_id':               value => $user_domain_id;
    'filter:authtoken/password':                     value => $password_real, secret => true;
    'filter:authtoken/project_name':                 value => $project_name_real;
    'filter:authtoken/project_domain_id':            value => $project_domain_id_real;
    'filter:authtoken/system_scope':                 value => $system_scope;
    'filter:authtoken/region_name':                  value => $region_name;
    'filter:authtoken/delay_auth_decision':          value => $delay_auth_decision;
    'filter:authtoken/cache':                        value => $cache;
    'filter:authtoken/include_service_catalog':      value => $include_service_catalog;
    'filter:authtoken/service_token_roles':          value => join(any2array($service_token_roles), ',');
    'filter:authtoken/service_token_roles_required': value => $service_token_roles_required;
    'filter:authtoken/service_type':                 value => $service_type;
    'filter:authtoken/interface':                    value => $interface,
  }
}
