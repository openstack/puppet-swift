#
# Copyright 2021 Thomas Goirand <zigo@debian.org>
#
# Author: Thomas Goirand <zigo@debian.org>
#
# == Class: swift::wsgi::uwsgi_account
#
# Configure the UWSGI service for Swift Account.
#
# == Parameters
#
# [*processes*]
#   (Optional) Number of processes.
#   Defaults to $::os_workers.
#
# [*listen_queue_size*]
#   (Optional) Socket listen queue size.
#   Defaults to 100
#
class swift::wsgi::uwsgi_account (
  $processes         = $::os_workers,
  $listen_queue_size = 100,
){

  include swift::deps

  if $::os_package_type != 'debian'{
    warning('This class is only valid for Debian, as other operating systems are not using uwsgi by default.')
  }

  swift_account_uwsgi_config {
    'uwsgi/processes': value => $processes;
    'uwsgi/listen':    value => $listen_queue_size;
  }
}
