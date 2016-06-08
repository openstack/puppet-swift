require 'puppet'
require 'mocha'
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'spec', 'fixtures', 'modules', 'inifile', 'lib', 'puppet', 'util', 'ini_file')
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'lib', 'puppet', 'provider', 'swift_storage_policy', 'ruby')
RSpec.configure do |config|
  config.mock_with :mocha
end
provider_class = Puppet::Type.type(:swift_storage_policy).provider(:ruby)
describe provider_class do

  let :swift_conf_no_policy do
'[swift-constraints]
max_header_size=8192

[swift-hash]
swift_hash_path_suffix=secrete
'
  end

  let :swift_conf_policy0 do
'[swift-constraints]
max_header_size=8192

[swift-hash]
swift_hash_path_suffix=secrete

[storage-policy:0]
name = Policy-0
aliases = gold, silver, taco
policy_type = replication
default = true
'
  end

  let :swift_conf_policy1 do
'[swift-constraints]
max_header_size=8192

[swift-hash]
swift_hash_path_suffix=secrete

[storage-policy:0]
name = Policy-0
aliases = gold, silver, taco
policy_type = replication
default = true


[storage-policy:1]
name = Policy-1
aliases = a, b, c
policy_type = replication
default = false
'
  end

  let :swift_conf_policy2 do
'[swift-constraints]
max_header_size=8192

[swift-hash]
swift_hash_path_suffix=secrete

[storage-policy:0]
name = Policy-0
aliases = gold, silver, taco
policy_type = replication
default = true


[storage-policy:1]
name = Policy-1
aliases = a, b, c
policy_type = replication
default = false


[storage-policy:2]
name = Policy-2
aliases = red, green, blue
policy_type = replication
default = false
'
  end

  def validate_file(expected_content, tmpfile)
    expect(File.read(tmpfile)).to eq expected_content
  end

  let :provider0 do
    described_class.new(
      Puppet::Type.type(:swift_storage_policy).new(
        :name        => '0',
        :policy_name => 'Policy-0',
        :aliases     => 'gold, silver, taco',
        :policy_type => 'replication',
        :default     => 'true',
        :provider    => :ruby
      )
    )
  end

  let :swift_conf do
    Tempfile.new('swift_conf_file')
  end

  describe 'defining a new valid swift_storage_policy with a policy in place should succeed' do
    before :each do
      File.open(swift_conf, 'w') do |fh|
        fh.write(swift_conf_no_policy)
      end
      @swiftconffile = swift_conf.path
      provider0.class.stubs(:get_swift_conf_file).returns @swiftconffile
    end

    it 'the swift_storage_policy 0 resource should contain the correct policy_title and name' do
      expect(provider0.policy_title).to eql 'storage-policy:0'
      expect(provider0.name).to eql '0'
    end

    it 'swift_storage_policy resources should create correct items in swift.conf and pass error checking' do
      # Testing the complete flow/cases of creating swift_storage_policy resources here in one block.
      # Spliting cases up across multiple "it" blocks doesn't appear to work well for a provider that calls
      # flush.  It appears that the testing needs to be done in one "it" block to duplicate the state puppet
      # would find when pre-fetching and flushing resources during a run.
      validate_file(swift_conf_no_policy, provider0.class.get_swift_conf_file)
      # Create policy 0,flush calls provider "write_policy".
      provider0.create
      provider0.flush
      # storage-policy:0 should exist and be found in swift.conf now.
      expect(provider0.exists?).to be_truthy
      expect(provider0.class.storage_policies).to eq (["storage-policy:0"])
      validate_file(swift_conf_policy0, provider0.class.get_swift_conf_file)

      provider1 = described_class.new(
        Puppet::Type.type(:swift_storage_policy).new(
          :name        => '1',
          :policy_name => 'Policy-1',
          :aliases     => 'a, b, c',
          :policy_type => 'replication',
          :default     => 'false',
          :provider    => :ruby
        )
      )
      provider1.class.stubs(:get_swift_conf_file).returns @swiftconffile
      # storage-policy:1 should not yet exist in swift.conf
      expect(provider1.exists?).to be_falsey
      # Create policy 1,flush calls provider "write_policy"
      provider1.create
      provider1.flush
      # storage-policy:0 and storage-policy:1 should exist
      expect(provider0.exists?).to be_truthy
      expect(provider1.exists?).to be_truthy
      # storage-policy:0 and storage-policy:1 should exist in swift.conf
      validate_file(swift_conf_policy1, provider0.class.get_swift_conf_file)
      validate_file(swift_conf_policy1, provider1.class.get_swift_conf_file)

      provider2 = described_class.new(
        Puppet::Type.type(:swift_storage_policy).new(
          :name        => '2',
          :policy_name => 'Policy-2',
          :aliases     => 'gold, red, green',
          :policy_type => 'replication',
          :default     => 'false',
          :provider    => :ruby
        )
      )
      provider2.class.stubs(:get_swift_conf_file).returns @swiftconffile
      # storage-policy:2 should raise an error for duplicate name/alias conflict with storage-policy:0
      provider2.create
      expect { provider2.flush }.to raise_error(Puppet::Error, /trying to set a duplicate name/)

      # storage-policy:0 and storage-policy:1 should exist in swift.conf
      validate_file(swift_conf_policy1, provider0.class.get_swift_conf_file)
      validate_file(swift_conf_policy1, provider1.class.get_swift_conf_file)
      # Set non duplicate alias on provider2 then create/flush again with no error
      provider2 = described_class.new(
        Puppet::Type.type(:swift_storage_policy).new(
          :name        => '2',
          :policy_name => 'Policy-2',
          :aliases     => 'red, green, blue',
          :policy_type => 'replication',
          :default     => 'false',
          :provider    => :ruby
        )
      )
      provider2.class.stubs(:get_swift_conf_file).returns @swiftconffile
      provider2.create
      expect { provider2.flush }.not_to raise_error
      # storage-policy:0,1,2 should exist in swift.conf
      validate_file(swift_conf_policy2, provider0.class.get_swift_conf_file)

      # attempt to set storage-policy:1 default=true, expect an error raised on conflict with storage-policy:0
      provider1 = described_class.new(
        Puppet::Type.type(:swift_storage_policy).new(
          :name        => '1',
          :policy_name => 'Policy-1',
          :aliases     => 'a, b, c',
          :policy_type => 'replication',
          :default     => 'true',
          :provider    => :ruby
        )
      )
      provider1.class.stubs(:get_swift_conf_file).returns @swiftconffile
      provider1.create
      expect { provider1.flush }.to raise_error(Puppet::Error, /default=true already set in a policy storage-policy:0/)
    end
  end
end
