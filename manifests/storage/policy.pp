# Class swift::storage::policy
#
# Setting any optional parameter to undef will remove it
# from the storage policy defined in swift.conf.
#
# == Parameters
#  [*ensure*]
#    (optional) To ensure a storage policy exists in swift.conf
#    set to 'present'.  To remove a storage policy from swift.conf
#    set to 'absent'.
#    Defaults to 'present'
#
#  [*policy_name*]
#    (required) Storage policy name in swift.conf
#    Names and aliases must be unique across all policies.
#
#  [*default_policy*]
#    (optional) Boolean to specify if this is the default storage policy
#    Defaults to true
#
#  [*policy_aliases*]
#    (optional) A comma separated string of aliases to use for this storage
#    policy. ex: 'gold, silver, taco' Names and aliases must be unique across
#    all policies.
#    Defaults to undef.
#
#  [*policy_index*]
#    (required) storage policy index. Becomes a storage policy section
#    header in swift.conf.
#    Defaults to '0'
#
#  [*policy_type*]
#    (required) Storage policy type. Can be 'replication' or 'erasure_coding'
#    Defaults 'replication'.
#
#  [*deprecated*]
#    (optional) Any policy may be deprecated by setting deprecated = yes.
#    Choices are 'yes', 'no', undef
#    Defaults to undef
#
#  [*ec_type*]
#    (optional) Specifies the EC scheme that is to be used
#    Defaults to undef
#
#  [*ec_num_data_fragments*]
#    (optional) The total number of fragments that will be
#    comprised of data.
#    Defaults to undef
#
#  [*ec_num_parity_fragments*]
#    (optional) The total number of fragments that will be
#    comprised of parity.
#    Defaults to undef
#
#  [*ec_object_segment_size*]
#    (optional) The amount of data that will be buffered up before
#    feeding a segment into the encoder/decoder in bytes.
#    Defaults to undef
#
define swift::storage::policy(
  $policy_name,
  $default_policy,
  $ensure                  = 'present',
  $policy_aliases          = undef,
  $policy_index            = $name,
  $policy_type             = 'replication',
  $deprecated              = undef,
  $ec_type                 = undef,
  $ec_num_data_fragments   = undef,
  $ec_num_parity_fragments = undef,
  $ec_object_segment_size  = undef,
) {

  include ::swift::deps

  Swift_storage_policy<| |> ~> Service<| tag == 'swift-service' |>

  if (downcase($policy_name) == 'policy-0') and ($policy_index != '0') {
    fail('The name Policy-0 can only be used with policy index 0')
  }

  if ($default_policy == true) and ($deprecated == 'yes') {
    fail('a deprecated policy may not also be declared the default')
  }

  swift_storage_policy { $policy_index:
    ensure                  => $ensure,
    policy_name             => $policy_name,
    aliases                 => $policy_aliases,
    policy_type             => $policy_type,
    default                 => bool2str($default_policy),
    deprecated              => $deprecated,
    ec_type                 => $ec_type,
    ec_num_data_fragments   => $ec_num_data_fragments,
    ec_num_parity_fragments => $ec_num_parity_fragments,
    ec_object_segment_size  => $ec_object_segment_size,
  }

}
