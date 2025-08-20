#
# Copyright (C) 2022 Red Hat
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
# == Class: swift::constraints
#
# Configre the [swift-constraints] options
#
# == Parameters
#
# [*max_file_size*]
#   (Optional) The largest "normal" object that can be saved in the cluster.
#   Defaults to $facts['os_service_default']
#
# [*max_meta_name_length*]
#   (Optional) Max number of bytes in the utf8 encoding of the name portion of
#   a metadata header.
#   Defaults to $facts['os_service_default']
#
# [*max_meta_value_length*]
#   (Optional) Max number of bytes in the utf8 encoding of a metadata value.
#   Defaults to $facts['os_service_default']
#
# [*max_meta_count*]
#   (Optional) Max number of metadata keys that can be store on a single
#   account, container or object.
#   Defaults to $facts['os_service_default']
#
# [*max_meta_overall_size*]
#   (Optional) The max number of bytes in the utf8 encoding of the metadata.
#   Defaults to $facts['os_service_default']
#
# [*max_header_size*]
#   (Optional) Max HTTP header size for incoming requests for all swift
#   services.
#   Defaults to $facts['os_service_default']
#
# [*extra_header_count*]
#   (Optional) Allow additional headers in addition to max allowed metadata
#   plus a default value of 36 for swift internally generated headers and
#   regular http headers.
#   Defaults to $facts['os_service_default']
#
# [*max_object_name_length*]
#   (Optional) Max number of bytes in the utf8 encoding of an object name.
#   Defaults to $facts['os_service_default']
#
# [*container_listing_limit*]
#   (Optional) Default (and max) number of items returned for a container
#   listing request.
#   Defaults to $facts['os_service_default']
#
# [*account_listing_limit*]
#   (Optional) Default (and max) number of items returned for an account
#   listing request.
#   Defaults to $facts['os_service_default']
#
# [*max_account_name_length*]
#   (Optional) Max number of bytes in the utf8 encoding of an account name.
#   Defaults to $facts['os_service_default']
#
# [*max_container_name_length*]
#   (Optional) Max number of bytes in the utf8 encoding of a container name.
#   Defaults to $facts['os_service_default']
#
# [*valid_api_versions*]
#   (Optional) Allowed version strings for all REST API calls.
#   Defaults to $facts['os_service_default']
#
# [*auto_create_account_prefix*]
#   (Optional) Prefix used for hiddne auto-created accounts.
#   Defaults to $facts['os_service_default']
#
class swift::constraints (
  $max_file_size              = $facts['os_service_default'],
  $max_meta_name_length       = $facts['os_service_default'],
  $max_meta_value_length      = $facts['os_service_default'],
  $max_meta_count             = $facts['os_service_default'],
  $max_meta_overall_size      = $facts['os_service_default'],
  $max_header_size            = $facts['os_service_default'],
  $extra_header_count         = $facts['os_service_default'],
  $max_object_name_length     = $facts['os_service_default'],
  $container_listing_limit    = $facts['os_service_default'],
  $account_listing_limit      = $facts['os_service_default'],
  $max_account_name_length    = $facts['os_service_default'],
  $max_container_name_length  = $facts['os_service_default'],
  $valid_api_versions         = $facts['os_service_default'],
  $auto_create_account_prefix = $facts['os_service_default'],
) {
  include swift::deps
  include swift::params

  swift_config {
    'swift-constraints/max_file_size':              value => $max_file_size;
    'swift-constraints/max_meta_name_length':       value => $max_meta_name_length;
    'swift-constraints/max_meta_value_length':      value => $max_meta_value_length;
    'swift-constraints/max_meta_count':             value => $max_meta_count;
    'swift-constraints/max_meta_overall_size':      value => $max_meta_overall_size;
    'swift-constraints/max_header_size':            value => $max_header_size;
    'swift-constraints/extra_header_count':         value => $extra_header_count;
    'swift-constraints/max_object_name_length':     value => $max_object_name_length;
    'swift-constraints/container_listing_limit':    value => $container_listing_limit;
    'swift-constraints/account_listing_limit':      value => $account_listing_limit;
    'swift-constraints/max_account_name_length':    value => $max_account_name_length;
    'swift-constraints/max_container_name_length':  value => $max_container_name_length;
    'swift-constraints/valid_api_versions':         value => join(any2array($valid_api_versions), ',');
    'swift-constraints/auto_create_account_prefix': value => $auto_create_account_prefix;
  }
}
