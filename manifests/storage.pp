#
# Configures dependencies that are common for all storage
# types.
#   - installs an rsync server
#   - installs required packages
#
# == Parameters
#  [*storage_local_net_ip*] ip address that the swift servers should
#    bind to. Required.
#
#  [*rsync_use_xinetd*] indicate if xinetd should be used to manage
#  rsync service, Default to True.
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift::storage(
  $storage_local_net_ip,
  $rsync_use_xinetd = true,
) {

  include swift::deps

  if !defined(Class['rsync::server']){
    class{ '::rsync::server':
      use_xinetd => $rsync_use_xinetd,
      address    => $storage_local_net_ip,
      use_chroot => 'no',
    }
  }
}
