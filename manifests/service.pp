# == Define: swift::service
#
# Wrapper class to configure swift service providers
#
# === Parameters:
#
# [*title*] The name of the swift service to manage
#   Mandatory. ex: 'swift-object-server' valid names
#   are listed in swift::params.pp at $swift_init_service_names
#
# [*os_family_service_name*]
#   (required) The distribution specific service name.
#
# [*config_file_name*]
#   (required) The service configuration file name.
#   Starting at the path "/etc/swift/" ex:"object-server.conf"
#
# [*service_ensure*]
#   (optional) State of service to ensure, running or stopped.
#   Default: undef
#
# [*enabled*]
#   (optional) Should the service be enabled to start
#    at boot. Default: true
#
# [*service_provider*]
#   (optional)
#   To use the swiftinit service provider to manage swift services, set
#   service_provider to "swiftinit".  When enable is true the provider
#   will populate boot files that start swift using swift-init at boot.
#   See README for more details.
#   Defaults to $::swift::params::service_provider.
#
define swift::service(
  $os_family_service_name,
  $config_file_name,
  $service_ensure   = undef,
  $enabled          = true,
  $service_provider = $::swift::params::service_provider,
) {

  include ::swift::deps
  include ::swift::params

  if(! member($::swift::params::swift_init_service_names, $name)) {
    fail("swift::service name: ${name} is not a valid swift_init_service_name")
  }

  if $service_provider != 'swiftinit' {
    service { $name:
      ensure    => $service_ensure,
      name      => $os_family_service_name,
      hasstatus => true,
      enable    => $enabled,
      provider  => $service_provider,
      tag       => 'swift-service',
      subscribe => $subscribe,
    }
  } elsif $service_provider == 'swiftinit' {
    service { $name:
      ensure     => $service_ensure,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      provider   => 'swiftinit',
      pattern    => $os_family_service_name,
      manifest   => $config_file_name,
      tag        => 'swift-service',
      subscribe  => $subscribe,
    }
  }
}
