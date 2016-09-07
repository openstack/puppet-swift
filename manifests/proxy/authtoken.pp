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
#    Defaults to '/var/cache/swift'
#
# [*cache*]
#    The cache backend to use
#    Optional. Defaults to 'swift.cache'
#
# [*auth_uri*]
#   (Optional) Complete public Identity API endpoint.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*auth_url*]
#   (Optional) The URL to use for authentication.
#   Defaults to 'http://127.0.0.1:35357'
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
# [*include_service_catalog*]
#   (Optional) Indicate whether to set the X-Service-Catalog header. If False,
#   middleware will not ask for service catalog on token validation and will
#   not set the X-Service-Catalog header. Boolean value.
#   Defaults to false
#
# == DEPRECATED
#
# [*admin_token*]
#   (optional) Deprecated.
#   Defaults to undef
#
# [*identity_uri*]
#   (optional) Deprecated. Use auth_url instead.
#   Defaults to undef
#
# [*admin_user*]
#   (optional) Deprecated. Use username instead.
#   Defaults to undef
#
# [*admin_tenant_name*]
#   (optional) Deprecated. Use project_name instead.
#   Defaults to undef
#
# [*admin_password*]
#   (optional) Deprecated. Use password instead.
#   Defaults to undef
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
  $delay_auth_decision     = 1,
  $signing_dir             = '/var/cache/swift',
  $cache                   = 'swift.cache',
  $auth_uri                = 'http://127.0.0.1:5000',
  $auth_url                = 'http://127.0.0.1:35357',
  $auth_plugin             = 'password',
  $project_domain_id       = 'default',
  $user_domain_id          = 'default',
  $project_name            = 'services',
  $username                = 'swift',
  $password                = 'password',
  $include_service_catalog = false,
  # DEPRECATED PARAMETERS
  $admin_user              = undef,
  $admin_tenant_name       = undef,
  $admin_password          = undef,
  $identity_uri            = undef,
  $admin_token             = undef,
) {

  include ::swift::deps

  if $admin_token {
    warning('admin_token is deprecated, has no usage and will be removed in the O release')
  }

  if $identity_uri {
    warning('identity_uri is deprecated and will be removed, please use auth_url instead')
  }

  if $admin_user {
    warning('admin_user is deprecated and will be removed, please use username instead')
  }

  if $admin_tenant_name {
    warning('admin_tenant_name is deprecated and will be removed, please use project_name instead')
  }

  if $admin_password {
    warning('admin_password is deprecated and will be removed, please use password isntead')
  }

  $auth_url_real = pick($identity_uri, $auth_url)
  $username_real = pick($admin_user, $username)
  $project_name_real = pick($admin_tenant_name, $project_name)
  $password_real = pick($admin_password, $password)

  file { $signing_dir:
    ensure                  => directory,
    mode                    => '0700',
    owner                   => 'swift',
    group                   => 'swift',
    selinux_ignore_defaults => true,
    require                 => Anchor['swift::config::begin'],
    before                  => Anchor['swift::config::end'],
  }

  concat::fragment { 'swift_authtoken':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/authtoken.conf.erb'),
    order   => '170',
  }

}
