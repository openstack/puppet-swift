#
# This class can be sed to manage keystone middleware for swift proxy
#
# == Parameters
#  [operator_roles] a list of keystone roles a user must have to gain
#    access to Swift.
#    Optional. Dfeaults to ['admin', 'SwiftOperator']
#    Must be an array of strings
#  [is_admin] Set to true to allow users to set ACLs on their account.
#    Optional. Defaults to true.
#
# == Authors
#
#  Dan Bode dan@puppetlabs.com
#  Francois Charlier fcharlier@ploup.net
#

class swift::proxy::keystone(
  $operator_roles      = ['admin', 'SwiftOperator'],
  $is_admin            = true
) {

  concat::fragment { 'swift_keystone':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/keystone.conf.erb'),
    order   => '79',
  }

}
