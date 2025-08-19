# Configure keymaster configuration file
#
# == Parameters
#
# [*password*]
#   (Required) String. The password to go with the Keystone username.
#
# [*api_class*]
#   (Required) String. The api_class tells Castellan which key manager to 
#   use to access the external key management system. The default value that
#   accesses Barbican is 'barbican', which resolve to
#   castellan.key_manager.barbican_key_manager.BarbicanKeyManager.
#
# [*key_id*]
#   (Required) String. The key_id is the identifier of the root secret stored
#   in the KMS. The key_id is the final part of the secret href returned in the
#   output of an 'openstack secret order get' command after an order to store
#   or create a key has been successfully completed.
#
# [*username*]
#   (Required) String. The Keystone username of the user used to access the key
#   from the KMS. The username shall be set to match an existing user.
#   Defaults to swift.
#
# [*project_name*]
#   (Optional) String. The Keystone project name. For security reasons,
#   it is recommended to set the project_name to a project separate from the
#   service project used by other OpenStack services. Thereby, if another
#   service is compromised, it will not have access to the Swift root
#   encryption secret. It is recommended that the swift user is the only one
#   that has a role in this project.
#   Defaults to service.
#
# [*project_id*]
#   (Optional) String. Instead of the project name, the project id may also
#   be used.
#
# [*auth_endpoint*]
#   (Required) String. The Keystone URL to authenticate to. The value of
#   auth_url may be set according to the value of auth_uri in
#   [filter:authtoken] in proxy-server.conf.
#
# [*barbican_endpoint*]
#   (Optional) String. Endpoint of the barbican service. This is useful in
#   a multi-region cluster, where Castellan otherwise doesn't know in what
#   region is the key. If there is only a single region in the deployment,
#   this value can be set to default.
#   Defaults to $facts['os_service_default'].
#
# [*project_domain_name*]
#   (Optional) String. The project domain name may optionally be specified.
#
# [*user_domain_name*]
#   (Optional) String. The user domain name may optionally be specified.
#
# [*project_domain_id*]
#   (Optional) String. Instead of the project domain name, the project domain
#   id may also be specified.
#   Defaults to 'default' (note the capitalization).
#
# [*user_domain_id*]
#   (Optional) String. Instead of the user domain name, the user domain
#   id may also be specified.
#   Defaults to 'default' (note the capitalization).
#
# [*meta_version_to_write*]
#   (Optional) Int. The version of crypto metadata to write.
#   Defaults to $facts['os_service_default']
#
# == Dependencies
#
# None
#
# == Authors
#
#   Thiago da Silva thiago@redhat.com
#
class swift::keymaster(
  String[1] $password,
  $api_class             = 'barbican',
  $key_id                = $facts['os_service_default'],
  $username              = 'swift',
  $project_name          = 'services',
  $project_id            = $facts['os_service_default'],
  $auth_endpoint         = $facts['os_service_default'],
  $barbican_endpoint     = $facts['os_service_default'],
  $project_domain_name   = $facts['os_service_default'],
  $user_domain_name      = $facts['os_service_default'],
  $project_domain_id     = 'default',
  $user_domain_id        = 'default',
  $meta_version_to_write = $facts['os_service_default'],
) {

  include swift::deps
  include swift::params

  file { '/etc/swift/keymaster.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => $swift::params::group,
    mode    => '0640',
    require => Anchor['swift::config::begin'],
    before  => Anchor['swift::config::end'],
  }
  File['/etc/swift/keymaster.conf'] -> Swift_keymaster_config<||>

  swift_keymaster_config {
    'kms_keymaster/api_class':             value => $api_class;
    'kms_keymaster/key_id':                value => $key_id;
    'kms_keymaster/username':              value => $username;
    'kms_keymaster/password':              value => $password, secret => true;
    'kms_keymaster/project_name':          value => $project_name;
    'kms_keymaster/project_id':            value => $project_id;
    'kms_keymaster/auth_endpoint':         value => $auth_endpoint;
    'kms_keymaster/barbican_endpoint':     value => $barbican_endpoint;
    'kms_keymaster/project_domain_name':   value => $project_domain_name;
    'kms_keymaster/user_domain_name':      value => $user_domain_name;
    'kms_keymaster/project_domain_id':     value => $project_domain_id;
    'kms_keymaster/user_domain_id':        value => $user_domain_id;
    'kms_keymaster/meta_version_to_write': value => $meta_version_to_write;
  }
}

