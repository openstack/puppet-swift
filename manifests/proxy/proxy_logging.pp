#
# Configure swift proxy-logging.
#
# == Authors
#
#   Joe Topjian joe@topjian.net
#
class swift::proxy::proxy_logging {

  include ::swift::deps

  concat::fragment { 'swift_proxy-logging':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/proxy-logging.conf.erb'),
    order   => '270',
  }
}
