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
  $ensure = 'present'
) {

  package { 'swiftclient':
    ensure => $ensure,
    name   => $::swift::params::client_package,
  }

}
