# == Class: swift::client
#
# Installs swift client.
#
# === Parameters
#
# [*ensure*]
#   (optional) Ensure state of the package.
#   Defaults to 'present'.
#
class swift::client (
  $ensure = $::swift::client_package_ensure
) {

  if $ensure {
    $real_ensure = $ensure
  } else {
    $real_ensure = 'present'
  }

  include ::swift::deps
  include ::swift::params

  package { 'swiftclient':
    ensure => $real_ensure,
    name   => $::swift::params::client_package,
    tag    => ['openstack','swift-support-package']
  }

}
