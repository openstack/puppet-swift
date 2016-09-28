# == Class: swift::proxy::s3token
#
# Configure swift s3token.
#
# === Parameters
#
# [*auth_host*]
#   (optional) The keystone host
#   Defaults to 127.0.0.1
#
# [*auth_port*]
#   (optional) The Keystone client API port
#   Defaults to 5000
#
# [*auth_protocol*]
#   (optional) http or https
#    Defaults to http
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
  $auth_host = '127.0.0.1',
  $auth_port = '35357',
  $auth_protocol = 'http'
) {

  include ::swift::deps

  swift_proxy_config {
    'filter:s3token/paste.filter_factory': value => 'keystonemiddleware.s3_token:filter_factory';
    'filter:s3token/auth_host':            value => $auth_host;
    'filter:s3token/auth_port':            value => $auth_port;
    'filter:s3token/auth_protocol':        value => $auth_protocol;
  }
}
