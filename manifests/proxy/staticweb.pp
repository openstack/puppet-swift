#
# Configure swift staticweb, see documentation for Swift staticweb middleware
# to understand more about configuration.
#
# == Dependencies
#
# == Examples
#
#  include 'swift::proxy::staticweb'
#
# == Authors
#
#   Mehdi Abaakouk <sileht@sileht.net>
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::staticweb() {

  include ::swift::deps

  concat::fragment { 'swift-proxy-staticweb':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/staticweb.conf.erb'),
    order   => '190',
  }

}
