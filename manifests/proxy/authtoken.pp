#
# This class can be used to manage keystone's authtoken middleware
# for swift proxy
#
# == Parameters
#  [admin_token] Keystone admin token that can serve as a shared secret
#    for authenticating. If this is choosen if is used instead of a user,tenant,password.
#    Optional. Defaults to false.
#  [admin_user] User used to authenticate service.
#    Optional. Defaults to admin
#  [admin_tenant_name] Tenant used to authenticate service.
#    Optional. Defaults to openstack.
#  [admin_password] Password used with user to authenticate service.
#    Optional. Defaults to ChangeMe.
#  [delay_decision] Set to 1 to support token-less access (anonymous access,
#    tempurl, ...)
#    Optional, Defaults to 0
#  [auth_host] Host providing the keystone service API endpoint. Optional.
#    Defaults to 127.0.0.1
#  [auth_port] Port where keystone service is listening. Optional.
#    Defaults to 3557.
#  [auth_protocol] Protocol to use to communicate with keystone. Optional.
#    Defaults to https.
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#

class swift::proxy::authtoken(
  $admin_user          = 'swift',
  $admin_tenant_name   = 'services',
  $admin_password      = 'password',
  $auth_host           = '127.0.0.1',
  $auth_port           = '35357',
  $auth_protocol       = 'http',
  $delay_auth_decision = 1,
  $admin_token         = false
) {

  $auth_uri = "${auth_protocol}://${auth_host}:5000"
  $fragment_title    = regsubst($name, '/', '_', 'G')

  concat::fragment { "swift_authtoken":
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/authtoken.conf.erb'),
    order   => '22',
  }

}
