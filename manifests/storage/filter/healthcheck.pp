#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
define swift::storage::filter::healthcheck {
  include swift::deps

  $config_type = "swift_${name}_config"

  create_resources($config_type, {
    'filter:healthcheck/use' => { 'value' => 'egg:swift#healthcheck' },
  })
}
