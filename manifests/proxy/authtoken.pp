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
# [*signing_dir*]
#    The cache directory for signing certificates.
#    Defaults to $::swift::params::signing_dir
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
# [*auth_plugin*]
#   (Optional) The plugin for authentication
#   Defaults to 'password'
#
# [*username*]
#   (Optional) The name of the service user
#   Defaults to 'swift'
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
# [*user_domain_id*]
#   (Optional) id of domain for $username
#   Defaults to 'default'
#
# [*region_name*]
#   (Optional) The region in which the identity server can be found.
#   Defaults to $::os_service_default.
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
#  Defaults to $::os_service_default.
#
# [*service_token_roles_required*]
#  (optional) backwards compatibility to ensure that the service tokens are
#  compared against a list of possible roles for validity
#  true/false
#  Defaults to $::os_service_default.
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
  $signing_dir                  = $::swift::params::signing_dir,
  $cache                        = 'swift.cache',
  $www_authenticate_uri         = 'http://127.0.0.1:5000',
  $auth_url                     = 'http://127.0.0.1:5000',
  $auth_plugin                  = 'password',
  $project_domain_id            = 'default',
  $user_domain_id               = 'default',
  $project_name                 = 'services',
  $username                     = 'swift',
  $password                     = 'password',
  $region_name                  = $::os_service_default,
  $include_service_catalog      = false,
  $service_token_roles          = $::os_service_default,
  $service_token_roles_required = $::os_service_default,
) inherits swift::params {

  include swift::deps

  if ($::os_package_type != 'debian') {
    file { $signing_dir:
      ensure                  => directory,
      mode                    => '0700',
      owner                   => 'swift',
      group                   => 'swift',
      selinux_ignore_defaults => true,
      require                 => Anchor['swift::config::begin'],
      before                  => Anchor['swift::config::end'],
    }
  }


  swift_proxy_config {
    'filter:authtoken/log_name':                     value => 'swift';
    'filter:authtoken/signing_dir':                  value => $signing_dir;
    'filter:authtoken/paste.filter_factory':         value => 'keystonemiddleware.auth_token:filter_factory';
    'filter:authtoken/www_authenticate_uri':         value => $www_authenticate_uri;
    'filter:authtoken/auth_url':                     value => $auth_url;
    'filter:authtoken/auth_plugin':                  value => $auth_plugin;
    'filter:authtoken/project_domain_id':            value => $project_domain_id;
    'filter:authtoken/user_domain_id':               value => $user_domain_id;
    'filter:authtoken/project_name':                 value => $project_name;
    'filter:authtoken/username':                     value => $username;
    'filter:authtoken/password':                     value => $password;
    'filter:authtoken/region_name':                  value => $region_name;
    'filter:authtoken/delay_auth_decision':          value => $delay_auth_decision;
    'filter:authtoken/cache':                        value => $cache;
    'filter:authtoken/include_service_catalog':      value => $include_service_catalog;
    'filter:authtoken/service_token_roles':          value => $service_token_roles;
    'filter:authtoken/service_token_roles_required': value => $service_token_roles_required;
  }
}
