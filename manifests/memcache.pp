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
# == Class: swift::memcache
#
# This class creates a memcache configuration file
#
#
# === Parameters
#
# [*memcache_servers*]
# You can use this single conf file instead of having memcache_servers set in
# several other conf files under [filter:cache] for example. You can specify
# multiple servers separated with commas, as in: 10.1.2.3:11211,10.1.2.4:11211
# Default to ['127.0.0.1:11211']
#
# [*memcache_serialization_support*]
# Sets how memcache values are serialized and deserialized:
# 0 = older, insecure pickle serialization
# 1 = json serialization but pickles can still be read (still insecure)
# 2 = json serialization only (secure and the default)
# To avoid an instant full cache flush, existing installations should
# upgrade with 0, then set to 1 and reload, then after some time (24 hours)
# set to 2 and reload.
# In the future, the ability to use pickle serialization will be removed.
# Default to $::os_service_default
#
# [*memcache_max_connections*]
# Sets the maximum number of connections to each memcached server per worker
# Default to $::os_service_default
#
# [*connect_timeout*]
# Timeout for connection
# Default to $::os_service_default
#
# [*pool_timeout*]
# Timeout for pooled connection
# Default to $::os_service_default
#
# [*tries*]
# number of servers to retry on failures getting a pooled connection
# Default to $::os_service_default
#
# [*io_timeout*]
# Timeout for read and writes
# Default to $::os_service_default
#
#
# === Authors
#
# shi.yan@ardc.edu.au
#
class swift::memcache (
  $memcache_servers               = ['127.0.0.1:11211'],
  $memcache_serialization_support = $::os_service_default,
  $memcache_max_connections       = $::os_service_default,
  $connect_timeout                = $::os_service_default,
  $pool_timeout                   = $::os_service_default,
  $tries                          = $::os_service_default,
  $io_timeout                     = $::os_service_default,
) {

  include swift::deps
  include swift::params


  file { '/etc/swift/memcache.conf':
    ensure => file,
    owner  => 'swift',
    group  => 'swift',
    mode   => '0640',
  }

  swift_memcache_config {
    'memcache/memcache_servers':               value => join(any2array($memcache_servers), ',');
    'memcache/memcache_serialization_support': value => $memcache_serialization_support;
    'memcache/memcache_max_connections':       value => $memcache_max_connections;
    'memcache/connect_timeout':                value => $connect_timeout;
    'memcache/pool_timeout':                   value => $pool_timeout;
    'memcache/tries':                          value => $tries;
    'memcache/io_timeout':                     value => $io_timeout;
  }
}
