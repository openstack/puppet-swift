# == Class: swift::proxy::swauth
#
# === Parameters:
#
# [*package_ensure*]
#   The status of the python-swauth package.
#   Defaults to 'present'
#
# [*swauth_endpoint*]
#   (optional) The endpoint used to autenticate to Swauth WSGI.
#   Defaults to '127.0.0.1'
#
# [*swauth_super_admin_key*]
#   (optional) The Swauth WSGI filter admin key.
#   Defaults to 'swauthkey'
#
#
class swift::proxy::swauth(
  $swauth_endpoint = '127.0.0.1',
  $swauth_super_admin_key = 'swauthkey',
  $package_ensure = 'present'
) {

  include ::swift::deps

  package { 'python-swauth':
    ensure => $package_ensure,
    tag    => 'swift-package',
  }

  Package['python-swauth'] -> Package<| title == 'swift-proxy' |>

  swift_proxy_config {
    'filter:swauth/use':                   value => 'egg:swauth#swauth';
    'filter:swauth/default_swift_cluster': value => "local#${swauth_endpoint}";
    'filter:swauth/super_admin_key':       value => $swauth_super_admin_key;
  }
}
