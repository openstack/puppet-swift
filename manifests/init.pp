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
#   (Required)String. A prefix used by hash_path to offer a bit more security
#   when generating hashes for paths. It simply appends this value to all paths;
#   if someone knows this suffix, it's easier for them to guess the hash a path
#   will end up with. New installations are advised to set this parameter to a
#   random secret, which would not be disclosed ouside the organization. The
#   same secret needs to be used by all swift servers of the same cluster.
#   Existing installations should set this parameter to an empty string.
#   as a salt when hashing to determine mappings in the ring.
#   This file should be the same on every node in the cluster.
#
# [*package_ensure*] The ensure state for the swift package.
#   (Optional) Defaults to present.
#
# [*client_package_ensure*] The ensure state for the swift client package.
#   (Optional) Defaults to present.
#
# [*max_header_size*] Max HTTP header size for incoming requests for all swift
#   services. Recommended size is 32768 for PKI keystone tokens.
#   (Optional) Defaults to 8192

## DEPRECATED PARAMETERS
#
# [*swift_hash_suffix*]
#   DEPRECATED. string of text to be used
#   as a salt when hashing to determine mappings in the ring.
#   This file should be the same on every node in the cluster.
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
  # DEPRECATED PARAMETERS
  $swift_hash_suffix      = undef,
) {

  include ::swift::params

  if ($swift_hash_suffix == undef and $swift_hash_path_suffix == undef) {
    fail('You must specify swift_hash_path_suffix')
  } elsif ($swift_hash_suffix != undef and $swift_hash_path_suffix == undef) {
    warning('swift_hash_suffix has been deprecated and should be replaced with swift_hash_path_suffix, this will be removed as part of the N-cycle')
    $swift_hash_path_suffix_real = $swift_hash_suffix
  } else {
    $swift_hash_path_suffix_real = $swift_hash_path_suffix
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

  File { owner => 'swift', group => 'swift', require => Package['swift'] }

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
    'swift-hash/swift_hash_path_suffix': value => $swift_hash_path_suffix_real;
    'swift-hash/swift_hash_path_prefix': value => $swift_hash_path_prefix;
    'swift-constraints/max_header_size': value => $max_header_size;
  }
}
