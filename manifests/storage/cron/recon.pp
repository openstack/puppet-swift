#
# Copyright (C) 2019 Red Hat
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
# == Class: swift::storage::cron::recon
#
# Configure cron job to reflect statistics related to async pendings into recon
#
# === Parameters
#
#  [*minute*]
#    (optional) Defaults to '*/5'.
#
#  [*hour*]
#    (optional) Defaults to '*'.
#
#  [*monthday*]
#    (optional) Defaults to '*'.
#
#  [*month*]
#    (optional) Defaults to '*'.
#
#  [*weekday*]
#    (optional) Defaults to '*'.
#
#  [*configfile*]
#    (optional) Path to object server config file.
#    Defaults to '/etc/swift/object-server.conf'.
#
#  [*user*]
#    (optional) User with access to swift files.
#    swift::storage::server::user will be used if this is undef.
#    Defaults to 'swift'.
#

class swift::storage::cron::recon(
  $minute     = '*/5',
  $hour       = '*',
  $monthday   = '*',
  $month      = '*',
  $weekday    = '*',
  $configfile = '/etc/swift/object-server.conf',
  $user       = $swift::params::user
) inherits swift::params {

  include swift::deps

  cron { 'swift-recon-cron':
    command     => "swift-recon-cron ${configfile}",
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => $user,
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday,
  }
}
