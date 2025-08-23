#
# Configure swift recon.
#
# == Parameters
#  [*cache_path*]
#    (Optional) The path for recon cache
#    Defaults to $facts['os_service_default']
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#   Francois Charlier fcharlier@ploup.net
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
define swift::storage::filter::recon (
  $cache_path = $facts['os_service_default'],
) {
  include swift::deps

  $config_type = "swift_${name}_config"

  create_resources($config_type, {
    'filter:recon/use'              => { 'value' => 'egg:swift#recon' },
    'filter:recon/recon_cache_path' => { 'value' => $cache_path },
  })
}
