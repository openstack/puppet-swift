Puppet::Type.newtype(:swift_storage_policy) do
  ensurable

  newparam(:name, :namevar => :true) do
    desc 'Storage policy id digit'
    validate do |value|
      value_match = /\d+/.match(value)
      next unless value_match.nil? || !value_match[0].eql?(value)
      fail('swift_storage_policy name must be a positive integer')
    end
    newvalues(/\d+/)
  end

  newproperty(:policy_name) do
    desc 'Storage policy_name. Policy names are case insensitive, must contain only letters,'\
         ' digits or a dash and must be unique.'
    validate do |value|
      value_match = /[a-zA-Z\d\-]+/.match(value)
      next unless value_match.nil? || !value_match[0].eql?(value)
      fail('policy_name must contain only letters, digits or a dash')
    end
    newvalues(/[a-zA-Z\d\-]+/)
  end

  newproperty(:aliases) do
    desc 'Storage policy aliases'
    validate do |value|
      value_match = /([a-zA-Z\d\-]+,\s+)+[a-zA-Z\d\-]+/.match(value)
      next unless value_match.nil? || !value_match[0].eql?(value)
      fail('aliases must contain only letters, digits or a dash in a comma separated string')
    end
    newvalues(/([a-zA-Z\d\-]+,\s)+/)
  end

  newproperty(:policy_type) do
    desc 'Type of storage policy, ec or replication'
    newvalues(/(replication)|(erasure_coding)/i)
  end

  newproperty(:default) do
    desc 'Set default on storage policy'
    newvalues(/(true)|(false)/)
  end

  newproperty(:deprecated) do
    desc 'Set to yes to mark a policy as deprecated'
    newvalues(/(yes)|(no)/i)
  end

  newproperty(:ec_type) do
    desc 'Type of erasure code to use'
    newvalues(/\w+/)
  end

  newproperty(:ec_num_data_fragments) do
    desc 'The total number of fragments that will be comprised of data.'
    newvalues(/\d+/)
  end

  newproperty(:ec_num_parity_fragments) do
    desc 'The total number of fragments that will be comprised of parity'
    newvalues(/\d+/)
  end

  newproperty(:ec_object_segment_size) do
    desc 'The amount of data that will be buffered up before feeding a segment into the encoder/decoder'
    newvalues(/\d+/)
  end
end
