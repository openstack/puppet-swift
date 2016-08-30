#
# Configure swift copy.
#
# == Examples
#
#  include ::swift::proxy::copy
#
# == Parameters
#
# [*object_post_as_copy*]
# Set object_post_as_copy = false to turn on fast posts where only the metadata
# changes are stored anew and the original data file is kept in place. This
# makes for quicker posts.
# When object_post_as_copy is set to true, a POST request will be transformed
# into a COPY request where source and destination objects are the same. This
# is the current default in Swift.
#
class swift::proxy::copy (
  $object_post_as_copy = true
) {

  include ::swift::deps

  concat::fragment { 'swift_copy':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/copy.conf.erb'),
    order   => '140',
  }

}
