# Install and configure base swift components
#
# == Parameters
#
# [*swift_hash_path_suffix*]
#   (Required) String. A suffix used by hash_path to offer a bit more security
#   when generating hashes for paths. It simply appends this value to all
#   paths; if someone knows this suffix, it's easier for them to guess the hash
#   a path will end up with. New installations are advised to set this
#   parameter to a random secret, which would not be disclosed ouside the
#   organization. The same secret needs to be used by all swift servers of the
#   same cluster. Existing installations should set this parameter to an empty
#   string.
#
# [*swift_hash_path_prefix*]
#   (Required) String. A prefix used by hash_path to offer a bit more security
#   when generating hashes for paths. It simply prepends this value to all paths;
#   if someone knows this prefix, it's easier for them to guess the hash a path
#   will end up with. New installations are advised to set this parameter to a
#   random secret, which would not be disclosed ouside the organization. The
#   same secret needs to be used by all swift servers of the same cluster.
#   Existing installations should set this parameter to an empty string.
#   as a salt when hashing to determine mappings in the ring.
#   This file should be the same on every node in the cluster.
#
# [*package_ensure*]
#   (Optional) The ensure state for the swift package.
#   Defaults to present.
#
# [*client_package_ensure*]
#   (Optional) The ensure state for the swift client package.
#   Defaults to present.
#
# [*max_header_size*]
#   (Optional) Max HTTP header size for incoming requests for all swift
#   services. Recommended size is 32768 for PKI keystone tokens.
#   Defaults to 8192
#
# == Dependencies
#
# None
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift(
  $swift_hash_path_suffix = undef,
  $swift_hash_path_prefix = undef,
  $package_ensure         = 'present',
  $client_package_ensure  = 'present',
  $max_header_size        = '8192',
) {

  include ::swift::deps
  include ::swift::params

  if ($swift_hash_path_prefix == undef and $swift_hash_path_suffix == undef) {
    fail('You must specify at least swift_hash_path_prefix or swift_hash_path_suffix')
  }

  if !defined(Package['swift']) {
    package { 'swift':
      ensure => $package_ensure,
      name   => $::swift::params::package_name,
      tag    => ['openstack', 'swift-package'],
    }
  }

  class { '::swift::client':
    ensure => $client_package_ensure;
  }

  File {
    owner   => 'swift',
    group   => 'swift',
    tag     => 'swift-file',
  }

  file { '/etc/swift':
    ensure => directory,
  }
  user {'swift':
    ensure  => present,
    require => Package['swift'],
  }
  file { '/var/lib/swift':
    ensure => directory,
  }
  file { '/var/run/swift':
    ensure                  => directory,
    selinux_ignore_defaults => true,
  }

  file { '/etc/swift/swift.conf':
    ensure => file,
  }

  File['/etc/swift/swift.conf'] -> Swift_config<||>

  swift_config {
    'swift-hash/swift_hash_path_suffix': value => $swift_hash_path_suffix;
    'swift-hash/swift_hash_path_prefix': value => $swift_hash_path_prefix;
    'swift-constraints/max_header_size': value => $max_header_size;
  }
}
