#
# Configure swift tempurl.
#
# == Parameters
#
#  [*methods*]
#    Methods allowed with Temp URLs.
#    Example: ['GET','HEAD','PUT','POST','DELETE'] or 'GET HEAD PUT POST DELETE'
#    Optional. Defaults to undef.
#
#  [*incoming_remove_headers*]
#    The headers to remove from incoming requests.
#    Example: ['x-timestamp'] or 'x-timestamp'
#    Optional. Defaults to undef.
#
#  [*incoming_allow_headers*]
#    The headers allowed as exceptions to incoming_remove_headers
#    Example: ['*'] or '*'
#    Optional. Defaults to undef.
#
#  [*outgoing_remove_headers*]
#    The headers to remove from outgoing responses
#    Example: ['x-object-meta-*'] or 'x-object-meta-*'
#    Optional. Defaults to undef.
#
#  [*outgoing_allow_headers*]
#    The headers allowed as exceptions to outgoing_remove_headers
#    Example: ['x-object-meta-public-*'] or 'x-object-meta-public-*'
#    Optional. Defaults to undef.
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
  $methods                 = undef,
  $incoming_remove_headers = undef,
  $incoming_allow_headers  = undef,
  $outgoing_remove_headers = undef,
  $outgoing_allow_headers  = undef,
) {

  include ::swift::deps

  if($methods) {
    if is_array($methods) {
      $methods_real = join($methods,' ')
    } elsif is_string($methods) {
      $methods_real = $methods
    }
  }

  if($incoming_remove_headers) {
    if is_array($incoming_remove_headers) {
      $incoming_remove_headers_real = join($incoming_remove_headers,' ')
    } elsif is_string($incoming_remove_headers) {
      $incoming_remove_headers_real = $incoming_remove_headers
    }
  }

  if($incoming_allow_headers) {
    if is_array($incoming_allow_headers) {
      $incoming_allow_headers_real = join($incoming_allow_headers,' ')
    } elsif is_string($incoming_allow_headers) {
      $incoming_allow_headers_real = $incoming_allow_headers
    }
  }

  if($outgoing_remove_headers) {
    if is_array($outgoing_remove_headers) {
      $outgoing_remove_headers_real = join($outgoing_remove_headers,' ')
    } elsif is_string($outgoing_remove_headers) {
      $outgoing_remove_headers_real = $outgoing_remove_headers
    }
  }

  if($outgoing_allow_headers) {
    if is_array($outgoing_allow_headers) {
      $outgoing_allow_headers_real = join($outgoing_allow_headers,' ')
    } elsif is_string($outgoing_allow_headers) {
      $outgoing_allow_headers_real = $outgoing_allow_headers
    }
  }


  swift_proxy_config {
    'filter:tempurl/use':                     value => 'egg:swift#tempurl';
    'filter:tempurl/methods':                 value => $methods_real;
    'filter:tempurl/incoming_remove_headers': value => $incoming_remove_headers_real;
    'filter:tempurl/incoming_allow_headers':  value => $incoming_allow_headers_real;
    'filter:tempurl/outgoing_remove_headers': value => $outgoing_remove_headers_real;
    'filter:tempurl/outgoing_allow_headers':  value => $outgoing_allow_headers_real;
  }
}
