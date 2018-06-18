# == Class: swift::proxy::s3token
#
# Configure swift s3token.
#
# === Parameters
#
# [*auth_host*]
#   (optional) The keystone host
#   Defaults to undef.
#
# [*auth_port*]
#   (optional) The Keystone client API port
#   Defaults to undef.
#
# [*auth_protocol*]
#   (optional) http or https
#    Defaults to undef.
#
# [*auth_uri*]
#   (optional) The Keystone server uri
#   Defaults to http://127.0.0.1:5000
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::s3token(
  $auth_host = undef,
  $auth_port = undef,
  $auth_protocol = undef,
  $auth_uri = 'http://127.0.0.1:5000'
) {

  include ::swift::deps

  if $auth_host and $auth_port and $auth_protocol {
    warning('Use of the auth_host, auth_port, and auth_protocol options have been deprecated in favor of auth_uri.')
    $auth_uri_real = "${auth_protocol}://${auth_host}:${auth_port}"
  } else {
    $auth_uri_real = $auth_uri
  }



  swift_proxy_config {
    'filter:s3token/use':                  value => 'egg:swift#s3token';
    'filter:s3token/auth_uri':             value => $auth_uri_real;
  }
}
