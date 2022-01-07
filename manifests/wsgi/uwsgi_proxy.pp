#
# Copyright 2021 Thomas Goirand <zigo@debian.org>
#
# Author: Thomas Goirand <zigo@debian.org>
#
# == Class: swift::wsgi::uwsgi_proxy
#
# Configure the UWSGI service for Swift Proxy.
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
class swift::wsgi::uwsgi_proxy (
  $processes         = $::os_workers,
  $listen_queue_size = 100,
){

  include swift::deps

  if $::operatingsystem != 'Debian'{
    warning('This class is only valid for Debian, as other operating systems are not using uwsgi by default.')
  }

  swift_proxy_uwsgi_config {
    'uwsgi/processes': value => $processes;
    'uwsgi/listen':    value => $listen_queue_size;
  }
}
