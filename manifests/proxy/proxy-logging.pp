#
# Configure swift proxy-logging.
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Joe Topjian joe@topjian.net
#
class swift::proxy::proxy-logging {

  concat::fragment { 'swift_proxy-logging':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/proxy-logging.conf.erb'),
    order   => '27',
  }

}
