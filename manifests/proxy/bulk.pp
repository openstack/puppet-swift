#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
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
# Configure Bulk
#
# === Parameters
#
# [*max_containers_per_extraction*]
#   (Optional) The maximum number of containers that can be extracted from
#   an archive.
#   Defaults to $::os_service_default.
#
# [*max_failed_extractions*]
#   (Optional) The maximum number of failed extractions allowed when an archive
#   has extraction failures.
#   Defaults to $::os_service_default.
#
# [*max_failed_deletes*]
#   (Optional) The maximum number of failed deletion allowed in a bulk delete
#   of objects and their container.
#   Defaults to $::os_service_default
#
# [*max_deletes_per_request*]
#   (Optional) The maximum number of deletes allowed by each request.
#   Defaults to $::os_service_default.
#
# [*delete_container_retry_count*]
#   (Optional) Number of retries to delete container in a bulk delete of
#   objects and their container.
#   Defaults to $::os_service_default.
#
# [*delete_concurrency*]
#   (Optional) The number of objects to delete at a time.
#   Defaults to $::os_service_default.
#
# [*yield_frequency*]
#   (Optional) The frequency the server will spit out an ' ' to keep
#   the connection alive while its processing the request.
#   Defaults to $::os_service_default.
#
class swift::proxy::bulk(
  $max_containers_per_extraction = $::os_service_default,
  $max_failed_extractions        = $::os_service_default,
  $max_failed_deletes            = $::os_service_default,
  $max_deletes_per_request       = $::os_service_default,
  $delete_container_retry_count  = $::os_service_default,
  $delete_concurrency            = $::os_service_default,
  $yield_frequency               = $::os_service_default,
) {

  include swift::deps

  swift_proxy_config {
    'filter:bulk/use':                           value => 'egg:swift#bulk';
    'filter:bulk/max_containers_per_extraction': value => $max_containers_per_extraction;
    'filter:bulk/max_failed_extractions':        value => $max_failed_extractions;
    'filter:bulk/max_failed_deletes':            value => $max_failed_deletes;
    'filter:bulk/max_deletes_per_request':       value => $max_deletes_per_request;
    'filter:bulk/delete_container_retry_count':  value => $delete_container_retry_count;
    'filter:bulk/delete_concurrency':            value => $delete_concurrency;
    'filter:bulk/yield_frequency':               value => $yield_frequency;
  }
}
