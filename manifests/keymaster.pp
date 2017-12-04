# Configure keymaster configuration file
#
# == Parameters
#
# [*api_class*]
#   (Required) String. The api_class tells Castellan which key manager to 
#   use to access the external key management system. The default value that
#   accesses Barbican is
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
# [*password*]
#   (Required) String. The password to go with the Keystone username.
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
# [*project_domain_name*]
#   (Optional) String. The project domain name may optionally be specififed.
#
# [*user_domain_name*]
#   (Optional) String. The user domain name may optionally be specififed.
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
# == Dependencies
#
# None
#
# == Authors
#
#   Thiago da Silva thiago@redhat.com
#
class swift::keymaster(

  $api_class           = 'castellan.key_manager.barbican_key_manager.BarbicanKeyManager',
  $key_id              = undef,
  $username            = 'swift',
  $password            = undef,
  $project_name        = 'service',
  $project_id          = undef,
  $auth_endpoint       = undef,
  $project_domain_name = undef,
  $user_domain_name    = undef,
  $project_domain_id   = 'default',
  $user_domain_id      = 'default',
) {

  include ::swift::deps

  swift_keymaster_config {
    'kms_keymaster/api_class': value => $api_class;
    'kms_keymaster/key_id': value => $key_id;
    'kms_keymaster/username': value => $username;
    'kms_keymaster/password': value => $password;
    'kms_keymaster/project_name': value => $project_name;
    'kms_keymaster/project_id': value => $project_id;
    'kms_keymaster/auth_endpoint': value => $auth_endpoint;
    'kms_keymaster/project_domain_name': value => $project_domain_name;
    'kms_keymaster/user_domain_name': value => $user_domain_name;
    'kms_keymaster/project_domain_id': value => $project_domain_id;
    'kms_keymaster/user_domain_id': value => $user_domain_id;
  }
}

