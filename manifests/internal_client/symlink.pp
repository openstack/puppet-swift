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
# Configure swift symlink middleware.
#
# == Example
#
# include swift::internal_client::symlink
#
# == Parameters
#
# [*symloop_max*]
# Symlinks can point to other symlinks provided the number of symlinks in a
# chain does not exceed the symloop_max value. If the number of chained
# symlinks exceeds the limit symloop_max a 409 (HTTPConflict) error
# response will be produced.
# Default to $::os_service_default
#
# == Authors
#
# shi.yan@ardc.edu.au
#
class swift::internal_client::symlink(
  $symloop_max = $::os_service_default,
) {

  include swift::deps

  swift_internal_client_config {
    'filter:symlink/use':         value => 'egg:swift#symlink';
    'filter:symlink/symloop_max': value => $symloop_max;
  }
}
