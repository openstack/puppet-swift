#
# Configure Swift Container Sync
#
# == Authors
#
#   Denis Egorenko <degorenko@mirantis.com>
#
class swift::proxy::container_sync() {
  concat::fragment { 'swift_container_sync':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/container_sync.conf.erb'),
    order   => '60',
  }
}
