#
# Configure Swift Container Sync
#
# == Parameters
#
# [*allow_full_urls*]
#  (Optional) Allow full URL values to be set for new X-Container-Sync-To
#  headers.
#  Defaults to $facts['os_service_default']
#
# [*current*]
#  (Optional) Set this to specify this clusters //realm/cluster as "current" in
#  /info.
#  Defaults to $facts['os_service_default']
#
# == Authors
#
#   Denis Egorenko <degorenko@mirantis.com>
#
class swift::proxy::container_sync(
  $allow_full_urls = $facts['os_service_default'],
  $current         = $facts['os_service_default'],
) {

  include swift::deps

  swift_proxy_config {
    'filter:container_sync/use':             value => 'egg:swift#container_sync';
    'filter:container_sync/allow_full_urls': value => $allow_full_urls;
    'filter:container_sync/current':         value => $current;
  }
}
