#
# Configure swift tempurl.
#
# == Parameters
#
#  [*methods*]
#    Methods allowed with Temp URLs.
#    Example: ['GET','HEAD','PUT','POST','DELETE'] or 'GET HEAD PUT POST DELETE'
#    Optional. Defaults to $facts['os_service_default'].
#
#  [*incoming_remove_headers*]
#    The headers to remove from incoming requests.
#    Example: ['x-timestamp'] or 'x-timestamp'
#    Optional. Defaults to $facts['os_service_default'].
#
#  [*incoming_allow_headers*]
#    The headers allowed as exceptions to incoming_remove_headers
#    Example: ['*'] or '*'
#    Optional. Defaults to $facts['os_service_default'].
#
#  [*outgoing_remove_headers*]
#    The headers to remove from outgoing responses
#    Example: ['x-object-meta-*'] or 'x-object-meta-*'
#    Optional. Defaults to $facts['os_service_default'].
#
#  [*outgoing_allow_headers*]
#    The headers allowed as exceptions to outgoing_remove_headers
#    Example: ['x-object-meta-public-*'] or 'x-object-meta-public-*'
#    Optional. Defaults to $facts['os_service_default'].
#
# == Examples
#
#  class {'swift::proxy::tempurl':
#    methods => ['GET','HEAD','PUT'],
#    incoming_remove_headers => 'x-timestamp-*',
#  }
#
# == Authors
#
#   Guilherme Maluf <guimalufb@gmail.com>
#   Mehdi Abaakouk <sileht@sileht.net>
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::tempurl (
  $methods                 = $facts['os_service_default'],
  $incoming_remove_headers = $facts['os_service_default'],
  $incoming_allow_headers  = $facts['os_service_default'],
  $outgoing_remove_headers = $facts['os_service_default'],
  $outgoing_allow_headers  = $facts['os_service_default'],
) {

  include swift::deps

  $methods_real                 = join(any2array($methods), ' ')
  $incoming_remove_headers_real = join(any2array($incoming_remove_headers), ' ')
  $incoming_allow_headers_real  = join(any2array($incoming_allow_headers), ' ')
  $outgoing_remove_headers_real = join(any2array($outgoing_remove_headers), ' ')
  $outgoing_allow_headers_real  = join(any2array($outgoing_allow_headers), ' ')

  swift_proxy_config {
    'filter:tempurl/use':                     value => 'egg:swift#tempurl';
    'filter:tempurl/methods':                 value => $methods_real;
    'filter:tempurl/incoming_remove_headers': value => $incoming_remove_headers_real;
    'filter:tempurl/incoming_allow_headers':  value => $incoming_allow_headers_real;
    'filter:tempurl/outgoing_remove_headers': value => $outgoing_remove_headers_real;
    'filter:tempurl/outgoing_allow_headers':  value => $outgoing_allow_headers_real;
  }
}
