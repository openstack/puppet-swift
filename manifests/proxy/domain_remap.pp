# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Configure swift domain_remap.
#
# == Examples
#
#  include swift::proxy::domain_remap
#
# == Parameters
#
# [*log_name*]
# The log name of domain_remap.
# Default to $::os_service_default
#
# [*log_facility*]
# The log facility of domain_remap.
# Default to $::os_service_default
#
# [*log_level*]
# The log level of domain_remap.
# Default to $::os_service_default
#
# [*log_headers*]
# The log headers of domain_remap.
# Default to $::os_service_default
#
# [*log_address*]
# The log address of domain_remap.
# Default to $::os_service_default
#
# [*storage_domain*]
# Specify the storage_domain that match your cloud, multiple domains
# can be specified separated by a comma.
# Default to $::os_service_default
#
# [*path_root*]
# Specify a root path part that will be added to the start of paths if not
# already present.
# Default to $::os_service_default
#
# [*reseller_prefixes*]
# A list of reseller_prefixes to lookup a reseller_prefix
# from the given account name.
# Default to $::os_service_default
#
# [*default_reseller_prefix*]
# The default reseller_prefix.
# It will be used if none of reseller_prexies match
# Default to $::os_service_default
#
# [*mangle_client_paths*]
# Enable legacy remapping behavior for versioned path requests.
# Default to $::os_service_default
#
# == Authors
#
#   shi.yan@ardc.edu.au
#
#
class swift::proxy::domain_remap(
  $log_name                = $::os_service_default,
  $log_facility            = $::os_service_default,
  $log_level               = $::os_service_default,
  $log_headers             = $::os_service_default,
  $log_address             = $::os_service_default,
  $storage_domain          = $::os_service_default,
  $path_root               = $::os_service_default,
  $reseller_prefixes       = $::os_service_default,
  $default_reseller_prefix = $::os_service_default,
  $mangle_client_paths     = $::os_service_default,
) {

  include swift::deps

  if !is_service_default($reseller_prefixes) and is_array($reseller_prefixes) {
    $reseller_prefixes_str = join($reseller_prefixes, ',')
  } else {
    $reseller_prefixes_str = $reseller_prefixes
  }

  swift_proxy_config {
    'filter:domain_remap/use':                      value => 'egg:swift#domain_remap';
    'filter:domain_remap/set log_name':             value => $log_name;
    'filter:domain_remap/set log_facility':         value => $log_facility;
    'filter:domain_remap/set log_level':            value => $log_level;
    'filter:domain_remap/set log_headers':          value => $log_headers;
    'filter:domain_remap/set log_address':          value => $log_address;
    'filter:domain_remap/storage_domain' :          value => $storage_domain;
    'filter:domain_remap/path_root':                value => $path_root;
    'filter:domain_remap/reseller_prefixes':        value => $reseller_prefixes_str;
    'filter:domain_remap/default_reseller_prefix':  value => $default_reseller_prefix;
    'filter:domain_remap/mangle_client_paths':      value => $mangle_client_paths;
  }
}
