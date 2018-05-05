#
# Configure swift swift3.
#
# == Dependencies
#
# == Parameters
#
# [*ensure*]
#   Enable or not swift3 middleware
#   Defaults to 'present'
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#   Joe Topjian joe@topjian.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::swift3(
  $ensure = 'present'
) {

  include ::swift::deps
  include ::swift::params

  package { 'swift-plugin-s3':
    ensure => $ensure,
    name   => $::swift::params::swift3,
    tag    => ['openstack','swift-package']
  }

  swift_proxy_config {
    'filter:swift3/use': value => 'egg:swift3#swift3';
  }
}
