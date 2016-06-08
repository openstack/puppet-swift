require 'puppet'
describe Puppet::Type.type(:swift_storage_policy) do

  it 'should pass if swift_storage_policy name is an integer' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1')
    }.to_not raise_error
  end

  it 'should fail if swift_storage_policy name is not an integer' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => 'a')
    }.to raise_error(Puppet::ResourceError, /swift_storage_policy name must be a postive integer/)
  end

  it 'should pass if policy_name is valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0')
    }.to_not raise_error
  end

  it 'should fail if policy_name is not valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy_0')
    }.to raise_error(Puppet::ResourceError, /policy_name must contain only letters, digits or a dash/)
  end

  it 'should pass if aliases is valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0', :aliases => 'Gold, Silver, taco')
    }.to_not raise_error
  end

  it 'should fail if aliases is  not valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0', :aliases => 'Gold, Sil_ver taco')
    }.to raise_error(Puppet::ResourceError, /aliases must contain only letters, digits or a dash in a comma separated string/)
  end

  it 'should pass if policy_type is valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0', :policy_type => 'replication')
    }.to_not raise_error
  end

  it 'should fail if policy_type is not valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0', :policy_type => 'other')
    }.to raise_error(Puppet::ResourceError, /Valid values match \/(replication)|(erasure_coding)/)
  end

  it 'should pass if default is valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0', :default => 'true')
    }.to_not raise_error
  end

  it 'should fail if default is not valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0', :default => 'other')
    }.to raise_error(Puppet::ResourceError, /Valid values match \/(true)|(false)/)
  end

  it 'should pass if deprecated is valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0', :deprecated => 'no')
    }.to_not raise_error
  end

  it 'should fail if deprecated is not valid' do
    expect {
      Puppet::Type.type(:swift_storage_policy).new(:name => '1', :policy_name => 'Policy-0', :deprecated => 'other')
    }.to raise_error(Puppet::ResourceError, /Valid values match \/(yes)|(no)/)
  end

end
