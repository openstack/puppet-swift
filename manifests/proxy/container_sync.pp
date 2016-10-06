#
# Configure Swift Container Sync
#
# == Authors
#
#   Denis Egorenko <degorenko@mirantis.com>
#
class swift::proxy::container_sync() {

  include ::swift::deps

  swift_proxy_config {
    'filter:container_sync/use': value => 'egg:swift#container_sync';
  }
}
