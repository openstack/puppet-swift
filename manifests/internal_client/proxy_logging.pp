#
# Configure swift proxy-logging.
#
# == Authors
#
#   Joe Topjian joe@topjian.net
#
class swift::internal_client::proxy_logging {

  include swift::deps

  swift_internal_client_config {
    'filter:proxy-logging/use': value => 'egg:swift#proxy_logging';
  }
}
