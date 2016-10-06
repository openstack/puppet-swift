#
# Configure swift proxy-logging.
#
# == Authors
#
#   Joe Topjian joe@topjian.net
#
class swift::proxy::proxy_logging {

  include ::swift::deps

  swift_proxy_config {
    'filter:proxy-logging/use': value => 'egg:swift#proxy_logging';
  }
}
