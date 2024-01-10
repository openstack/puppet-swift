# == Class: swift::proxy::cname_lookup
#
# Configure CNAME Lookup middleware for swift
#
# === Parameters
#
# [*log_name*]
# The log name of cname_lookup.
# Default to $facts['os_service_default']
#
# [*log_facility*]
# The log facility of cname_lookup.
# Default to $facts['os_service_default']
#
# [*log_level*]
# The log level of cname_lookup.
# Default to $facts['os_service_default']
#
# [*log_headers*]
# The log headers of cname_lookup.
# Default to $facts['os_service_default']
#
# [*log_address*]
# The log address of cname_lookup.
# Default to $facts['os_service_default']
#
# [*storage_domain*]
# Specify the storage_domain that match your cloud, multiple domains
# can be specified separated by a comma.
# Default to $facts['os_service_default']
#
# [*lookup_depth*]
# Because CNAMES can be recursive, specifies the number of levels
# through which to search.
# Default to $facts['os_service_default']
#
# [*nameservers*]
# Specify the nameservers to use to do the CNAME resolution. If unset, the
# system configuration is used. Multiple nameservers can be specified
# separated by a comma. Default port 53 can be overridden. IPv6 is accepted.
# Example: 127.0.0.1, 127.0.0.2, 127.0.0.3:5353, [::1], [::1]:5353
# Default to $facts['os_service_default']
#
#
class swift::proxy::cname_lookup(
  $log_name       = $facts['os_service_default'],
  $log_facility   = $facts['os_service_default'],
  $log_level      = $facts['os_service_default'],
  $log_headers    = $facts['os_service_default'],
  $log_address    = $facts['os_service_default'],
  $storage_domain = $facts['os_service_default'],
  $lookup_depth   = $facts['os_service_default'],
  $nameservers    = $facts['os_service_default'],
) {

  include swift::deps
  include swift::params

  Package['python3-dnspython'] ~> Service<| tag == 'swift-proxy-service' |>

  swift_proxy_config {
    'filter:cname_lookup/use':              value => 'egg:swift#cname_lookup';
    'filter:cname_lookup/set log_name':     value => $log_name;
    'filter:cname_lookup/set log_facility': value => $log_facility;
    'filter:cname_lookup/set log_level':    value => $log_level;
    'filter:cname_lookup/set log_headers':  value => $log_headers;
    'filter:cname_lookup/set log_address':  value => $log_address;
    'filter:cname_lookup/storage_domain' :  value => $storage_domain;
    'filter:cname_lookup/lookup_depth' :    value => $lookup_depth;
    'filter:cname_lookup/nameservers' :     value => $nameservers;
  }

  package { 'python-dnspython':
    ensure => 'present',
    name   => $::swift::params::dnspython_package_name,
    tag    => ['openstack', 'swift-support-package'],
  }
}
