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
#    it will generate these lines
#      user_admin_admin = admin .admin .reseller_admin
#      user_bar_foo = pass
#
# == Authors
#
#   Guilherme Maluf Balzana <guimalufb@gmail.com>
#
class swift::proxy::tempauth (
  Array[Hash] $account_user_list                                 = [
    {
      'user'    => 'admin',
      'account' => 'admin',
      'key'     => 'admin',
      'groups'  => [ 'admin', 'reseller_admin' ],
    },
  ],
  Optional[String[1]] $reseller_prefix                           = undef,
  Optional[Pattern[/\/(.*)+\//]] $auth_prefix                    = undef,
  Optional[Integer[0]] $token_life                               = undef,
  Optional[Boolean] $allow_overrides                             = undef,
  Optional[Enum['http', 'https', 'default']] $storage_url_scheme = undef,
) {

  include swift::deps

  if ($reseller_prefix) {
    $reseller_prefix_upcase = upcase($reseller_prefix)
  } else {
    $reseller_prefix_upcase = $reseller_prefix
  }

  swift_proxy_config {
    'filter:tempauth/use':                value => 'egg:swift#tempauth';
    'filter:tempauth/reseller_prefix':    value => $reseller_prefix_upcase;
    'filter:tempauth/token_life':         value => $token_life;
    'filter:tempauth/auth_prefix':        value => $auth_prefix;
    'filter:tempauth/storage_url_scheme': value => $storage_url_scheme;
  }

  # tempauth account_users end up in the following format
  # user_<account>_<user> = <key> .<group1> .<groupx>
  # ex: user_admin_admin=admin .admin .reseller_admin
  # account_data is an array with each element containing a single account string:
  # ex [user_<account>_<user>, <key> .<group1> .<groupx>]
  $account_user_list.each |$account_user| {
    validate_tempauth_account($account_user)

    $account_base = "user_${account_user['account']}_${account_user['user']}, ${account_user['key']}"
    $groups = empty($account_user) ? {
      true    => undef,
      default => join([''] + $account_user['groups'], ' .')
    }

    $account_data = join(delete_undef_values([$account_base, $groups]), '')

    # write each temauth account line to file
    swift::proxy::tempauth_account { $account_data: }
  }
}
