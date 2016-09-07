# == class: swift::proxy::tempauth
# This class manages tempauth middleware
#
#  [*reseller_prefix*]
#    The naming scope for the auth service. Swift storage accounts and
#    auth tokens will begin with this prefix.
#    Optional. Defaults to 'undef'
#    Example: 'AUTH'.
#
#  [*auth_prefix*]
#    The HTTP request path prefix for the auth service. Swift itself
#    reserves anything beginning with the letter v.
#    Optional. Defaults to 'undef'
#    Example: '/auth/'
#
#  [*token_life*]
#   The number of seconds a token is valid.
#    Optional. Integer value. Defaults to 'undef'.
#    Example: 81600
#
#  [*allow_overrides*]
#    Allows middleware higher in the WSGI pipeline to override auth
#    processing
#    Optional. Boolean. Defaults to 'undef'
#    Example: true
#
#  [*storage_url_scheme*]
#    Scheme to return with storage urls: http, https, or default
#    Optional. Possible values: http, https or default. Defaults to 'undef'
#
#  [*account_user_list*]
#    List all the accounts/users you want in an array of hash format.
#    'user' and 'account' should not include '_' (TODO).
#    Defaults to:
#      account_user_list => [
#        {
#          'user'    => 'admin',
#          'account' => 'admin',
#          'key'     => 'admin',
#          'groups'  => [ 'admin', 'reseller_admin' ],
#        }
#      ]
#
#    Example of two account/user:
#      account_user_list => [
#        {
#          'user'    => 'admin',
#          'account' => 'admin',
#          'key'     => 'admin',
#          'groups'  => [ 'admin', 'reseller_admin' ],
#        },
#        {
#          'user'    => 'foo',
#          'account' => 'bar',
#          'key'     => 'pass',
#          'groups'  => [],
#        },
#      ]
#
#    it will gerenate these lines
#      user_admin_admin = admin .admin .reseller_admin
#      user_bar_foo = pass
#
# == Authors
#
#   Guilherme Maluf Balzana <guimalufb@gmail.com>
#
class swift::proxy::tempauth (
  $account_user_list  = [
    {
      'user'    => 'admin',
      'account' => 'admin',
      'key'     => 'admin',
      'groups'  => [ 'admin', 'reseller_admin' ],
    },
  ],
  $reseller_prefix    = undef,
  $auth_prefix        = undef,
  $token_life         = undef,
  $allow_overrides    = undef,
  $storage_url_scheme = undef,
) {

  include ::swift::deps

  validate_array($account_user_list)

  if ($reseller_prefix) {
    validate_string($reseller_prefix)
  }

  if ($token_life) {
    validate_integer($token_life)
  }

  if ($auth_prefix) {
    validate_re($auth_prefix,'\/(.*)+\/')
  }

  if ($allow_overrides) {
    validate_bool($allow_overrides)
  }

  if ($storage_url_scheme) {
    validate_re($storage_url_scheme, ['http','https','default'])
  }

  concat::fragment { 'swift-proxy-tempauth':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/tempauth.conf.erb'),
    order   => '150',
  }

}
