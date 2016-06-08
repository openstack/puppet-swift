require 'puppet'
require 'mocha'
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'lib', 'puppet', 'provider', 'ring_object_device', 'swift_ring_builder')
RSpec.configure do |config|
  config.mock_with :mocha
end
provider_class = Puppet::Type.type(:ring_object_device).provider(:swift_ring_builder)
describe provider_class do

  it "should have the SwiftRingBuilder provider class as its baseclass" do
    expect(provider_class.superclass).to equal(Puppet::Provider::SwiftRingBuilder)
  end

  let :builder_file_path do
    '/etc/swift/object.builder'
  end

  let :provider do
    described_class.new(
      Puppet::Type.type(:ring_object_device).new(
        :name     => '192.168.101.13:6002/1',
        :zone     => '1',
        :weight   => '1',
        :provider => :swift_ring_builder
      )
    )
  end

  let :object_builder_output_2_9_1 do
'/etc/swift/object.builder, build version 3
262144 partitions, 3 replicas, 3 zones, 3 devices, 0.00 balance
The minimum number of hours before a partition can be reassigned is 1
The overload factor is 0.00% (0.000000)
Devices:    id  region  zone    ip address:port       replic_ip:replic_port              name weight partitions balance meta
             1     1     1  192.168.101.13:6002         192.168.101.13:6002                 1   1.00     262144 0.00
             2     1     2  192.168.101.14:6002         192.168.101.14:6002                 1   1.00     262144 200.00  m2
             0     1     3  192.168.101.15:6002         192.168.101.15:6002                 1   1.00     262144-100.00  m2
             3     1     1  192.168.101.16:6002         192.168.101.16:6002                 1   1.00     262144-100.00
'
  end

  describe "with no storage policy_index set on swift 2.9.1+" do

    it 'object builder file should be object.builder when object name has no policy_index' do
      policy_index = provider.policy_index
      expect(provider.builder_file_path(policy_index)).to eq builder_file_path
    end

    it 'object builder file should be object.builder when object is invoked with policy_index 0' do
      expect(provider.builder_file_path(0)).to eq builder_file_path
    end

    it 'object builder file should not be object-1.builder when object name has no policy_index' do
      policy_index = provider.policy_index
      expect(provider.builder_file_path(policy_index)).to_not eq builder_file_path_policy1
    end

    it 'object builder file should not be object-1.builder when object is invoked with policy_index 0' do
      expect(provider.builder_file_path(0)).to_not eq builder_file_path_policy1
    end

    it 'ring_object_device should exist when found in builder file' do
      provider.expects(:swift_ring_builder).returns object_builder_output_2_9_1
      File.expects(:exists?).with(builder_file_path).returns(true)
      expect(provider.exists?).to eq({:id=>"1", :region=>"1", :zone=>"1", :weight=>"1.00", :partitions=>"262144", :balance=>"0.00", :meta=>"", :policy_index=>''})
    end

    it 'should be able to lookup the local ring' do
      File.expects(:exists?).with(builder_file_path).returns(true)
      provider.expects(:builder_file_path).twice.returns(builder_file_path)
      provider.expects(:swift_ring_builder).returns object_builder_output_2_9_1
      resources = provider.lookup_ring
      expect(resources['192.168.101.13:6002/1']).to_not be_nil
      expect(resources['192.168.101.14:6002/1']).to_not be_nil
      expect(resources['192.168.101.15:6002/1']).to_not be_nil
      expect(resources['192.168.101.16:6002/1']).to_not be_nil

      expect(resources['192.168.101.13:6002/1'][:id]).to eql '1'
      expect(resources['192.168.101.13:6002/1'][:region]).to eql '1'
      expect(resources['192.168.101.13:6002/1'][:zone]).to eql '1'
      expect(resources['192.168.101.13:6002/1'][:weight]).to eql '1.00'
      expect(resources['192.168.101.13:6002/1'][:partitions]).to eql '262144'
      expect(resources['192.168.101.13:6002/1'][:balance]).to eql '0.00'
      expect(resources['192.168.101.13:6002/1'][:meta]).to eql ''
      expect(resources['192.168.101.13:6002/1'][:policy_index]).to eql ''

      expect(resources['192.168.101.14:6002/1'][:id]).to eql '2'
      expect(resources['192.168.101.14:6002/1'][:region]).to eql '1'
      expect(resources['192.168.101.14:6002/1'][:zone]).to eql '2'
      expect(resources['192.168.101.14:6002/1'][:weight]).to eql '1.00'
      expect(resources['192.168.101.14:6002/1'][:partitions]).to eql '262144'
      expect(resources['192.168.101.14:6002/1'][:balance]).to eql '200.00'
      expect(resources['192.168.101.14:6002/1'][:meta]).to eql 'm2'
      expect(resources['192.168.101.14:6002/1'][:policy_index]).to eql ''
    end
  end

  let :builder_file_path_policy1 do
    '/etc/swift/object-1.builder'
  end

  let :provider_policy1 do
    described_class.new(
      Puppet::Type.type(:ring_object_device).new(
        :name     => '1:192.168.101.13:6002/1',
        :zone     => '1',
        :weight   => '1',
        :provider => :swift_ring_builder
      )
    )
  end

  let :object_builder_policy1_output_2_9_1 do
'/etc/swift/object-1.builder, build version 3
262144 partitions, 3 replicas, 3 zones, 3 devices, 0.00 balance
The minimum number of hours before a partition can be reassigned is 1
The overload factor is 0.00% (0.000000)
Devices:    id  region  zone    ip address:port       replic_ip:replic_port              name weight partitions balance meta
             1     1     1  192.168.101.13:6002         192.168.101.13:6002                 1   1.00     262144 0.00
             2     1     2  192.168.101.14:6002         192.168.101.14:6002                 1   1.00     262144 200.00  m2
             0     1     3  192.168.101.15:6002         192.168.101.15:6002                 1   1.00     262144-100.00  m2
             3     1     1  192.168.101.16:6002         192.168.101.16:6002                 1   1.00     262144-100.00
'
  end

  describe "with a storage policy_index set on swift 2.9.1+" do

    it 'object builder file should be object-1.builder when object name has policy_index 1' do
      policy_index = provider_policy1.policy_index
      expect(provider_policy1.builder_file_path(policy_index)).to eq builder_file_path_policy1
    end

    it 'object builder file should not be object.builder when object names has policy_index 1' do
      policy_index = provider_policy1.policy_index
      expect(provider_policy1.builder_file_path(policy_index)).to_not eq builder_file_path
    end

    it 'ring_object_device should exist when found in builder file with policy_index=1' do
      provider_policy1.expects(:swift_ring_builder).returns object_builder_policy1_output_2_9_1
      File.expects(:exists?).with(builder_file_path_policy1).returns(true)
      expect(provider_policy1.exists?).to eq({:id=>"1", :region=>"1", :zone=>"1", :weight=>"1.00", :partitions=>"262144", :balance=>"0.00", :meta=>"", :policy_index=>"1"})
    end

    it 'lookup local ring and object resource names should start with policy_index if a policy is set' do
      File.expects(:exists?).with(builder_file_path_policy1).returns(true)
      provider_policy1.expects(:builder_file_path).twice.returns(builder_file_path_policy1)
      provider_policy1.expects(:swift_ring_builder).returns object_builder_output_2_9_1
      resources = provider_policy1.lookup_ring
      expect(resources['1:192.168.101.13:6002/1']).to_not be_nil
      expect(resources['1:192.168.101.14:6002/1']).to_not be_nil
      expect(resources['1:192.168.101.15:6002/1']).to_not be_nil
      expect(resources['1:192.168.101.16:6002/1']).to_not be_nil

      expect(resources['1:192.168.101.13:6002/1'][:id]).to eql '1'
      expect(resources['1:192.168.101.13:6002/1'][:region]).to eql '1'
      expect(resources['1:192.168.101.13:6002/1'][:zone]).to eql '1'
      expect(resources['1:192.168.101.13:6002/1'][:weight]).to eql '1.00'
      expect(resources['1:192.168.101.13:6002/1'][:partitions]).to eql '262144'
      expect(resources['1:192.168.101.13:6002/1'][:balance]).to eql '0.00'
      expect(resources['1:192.168.101.13:6002/1'][:meta]).to eql ''
      expect(resources['1:192.168.101.13:6002/1'][:policy_index]).to eql '1'

      expect(resources['1:192.168.101.14:6002/1'][:id]).to eql '2'
      expect(resources['1:192.168.101.14:6002/1'][:region]).to eql '1'
      expect(resources['1:192.168.101.14:6002/1'][:zone]).to eql '2'
      expect(resources['1:192.168.101.14:6002/1'][:weight]).to eql '1.00'
      expect(resources['1:192.168.101.14:6002/1'][:partitions]).to eql '262144'
      expect(resources['1:192.168.101.14:6002/1'][:balance]).to eql '200.00'
      expect(resources['1:192.168.101.14:6002/1'][:meta]).to eql 'm2'
      expect(resources['1:192.168.101.14:6002/1'][:policy_index]).to eql '1'
    end
  end


  it 'should be able to lookup the local ring and build an object 2.2.2+' do
    # Swift 1.8 output
    provider.expects(:swift_ring_builder).returns(
'/etc/swift/object.builder, build version 3
262144 partitions, 3 replicas, 3 zones, 3 devices, 0.00 balance
The minimum number of hours before a partition can be reassigned is 1
The overload factor is 0.00% (0.000000)
Devices:    id  region  zone      ip address  port      replication ip  replication port name weight partitions balance meta
             1     1     1  192.168.101.13  6002         192.168.101.13  6002            1   1.00     262144 0.00
             2     1     2  192.168.101.14  6002         192.168.101.14  6002            1   1.00     262144 200.00  m2
             0     1     3  192.168.101.15  6002         192.168.101.15  6002            1   1.00     262144-100.00  m2
             3     1     1  192.168.101.16  6002         192.168.101.16  6002            1   1.00     262144-100.00
'
    )
    File.expects(:exists?).with(builder_file_path).returns(true)
    provider.expects(:builder_file_path).twice.returns(builder_file_path)
    resources = provider.lookup_ring
    expect(resources['192.168.101.13:6002/1']).to_not be_nil
    expect(resources['192.168.101.14:6002/1']).to_not be_nil
    expect(resources['192.168.101.15:6002/1']).to_not be_nil
    expect(resources['192.168.101.16:6002/1']).to_not be_nil

    expect(resources['192.168.101.13:6002/1'][:id]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:region]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:zone]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.13:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.13:6002/1'][:balance]).to eql '0.00'
    expect(resources['192.168.101.13:6002/1'][:meta]).to eql ''

    expect(resources['192.168.101.14:6002/1'][:id]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:region]).to eql '1'
    expect(resources['192.168.101.14:6002/1'][:zone]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.14:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.14:6002/1'][:balance]).to eql '200.00'
    expect(resources['192.168.101.14:6002/1'][:meta]).to eql 'm2'
  end

  it 'should be able to lookup the local ring and build an object 1.8+' do
    # Swift 1.8+ output
    provider_class.expects(:swift_ring_builder).returns(
'/etc/swift/object.builder, build version 3
262144 partitions, 3 replicas, 3 zones, 3 devices, 0.00 balance
The minimum number of hours before a partition can be reassigned is 1
Devices:    id  region  zone      ip address  port      replication ip  replication port name weight partitions balance meta
             1     1     1  192.168.101.13  6002         192.168.101.13  6002            1   1.00     262144 0.00
             2     1     2  192.168.101.14  6002         192.168.101.14  6002            1   1.00     262144 200.00  m2
             0     1     3  192.168.101.15  6002         192.168.101.15  6002            1   1.00     262144-100.00  m2
             3     1     1  192.168.101.16  6002         192.168.101.16  6002            1   1.00     262144-100.00
'
    )
    File.expects(:exists?).with(builder_file_path).returns(true)
    provider.expects(:builder_file_path).twice.returns(builder_file_path)
    resources = provider.lookup_ring
    expect(resources['192.168.101.13:6002/1']).to_not be_nil
    expect(resources['192.168.101.14:6002/1']).to_not be_nil
    expect(resources['192.168.101.15:6002/1']).to_not be_nil
    expect(resources['192.168.101.16:6002/1']).to_not be_nil

    expect(resources['192.168.101.13:6002/1'][:id]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:region]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:zone]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.13:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.13:6002/1'][:balance]).to eql '0.00'
    expect(resources['192.168.101.13:6002/1'][:meta]).to eql ''

    expect(resources['192.168.101.14:6002/1'][:id]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:region]).to eql '1'
    expect(resources['192.168.101.14:6002/1'][:zone]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.14:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.14:6002/1'][:balance]).to eql '200.00'
    expect(resources['192.168.101.14:6002/1'][:meta]).to eql 'm2'
  end

  it 'should be able to lookup the local ring and build an object 1.8.0' do
    # Swift 1.8 output
    provider_class.expects(:swift_ring_builder).returns(
'/etc/swift/object.builder, build version 3
262144 partitions, 3 replicas, 3 zones, 3 devices, 0.00 balance
The minimum number of hours before a partition can be reassigned is 1
Devices:    id  region  zone      ip address  port      name weight partitions balance meta
             1     1     1  192.168.101.13  6002         1   1.00     262144 0.00
             2     1     2  192.168.101.14  6002         1   1.00     262144 200.00  m2
             0     1     3  192.168.101.15  6002         1   1.00     262144-100.00  m2
             3     1     1  192.168.101.16  6002         1   1.00     262144-100.00
'
    )
    File.expects(:exists?).with(builder_file_path).returns(true)
    provider.expects(:builder_file_path).twice.returns(builder_file_path)
    resources = provider.lookup_ring
    expect(resources['192.168.101.13:6002/1']).to_not be_nil
    expect(resources['192.168.101.14:6002/1']).to_not be_nil
    expect(resources['192.168.101.15:6002/1']).to_not be_nil
    expect(resources['192.168.101.16:6002/1']).to_not be_nil

    expect(resources['192.168.101.13:6002/1'][:id]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:region]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:zone]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.13:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.13:6002/1'][:balance]).to eql '0.00'
    expect(resources['192.168.101.13:6002/1'][:meta]).to eql ''

    expect(resources['192.168.101.14:6002/1'][:id]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:region]).to eql '1'
    expect(resources['192.168.101.14:6002/1'][:zone]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.14:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.14:6002/1'][:balance]).to eql '200.00'
    expect(resources['192.168.101.14:6002/1'][:meta]).to eql 'm2'
  end

  it 'should be able to lookup the local ring and build an object 1.7' do
    # Swift 1.7 output
    provider_class.expects(:swift_ring_builder).returns(
'/etc/swift/object.builder, build version 3
262144 partitions, 3 replicas, 3 zones, 3 devices, 0.00 balance
The minimum number of hours before a partition can be reassigned is 1
Devices:    id  region  zone      ip address  port      name weight partitions balance meta
             1     1     1  192.168.101.13  6002         1   1.00     262144    0.00
             2     1     2  192.168.101.14  6002         1   1.00     262144    0.00
             0     1     3  192.168.101.15  6002         1   1.00     262144    0.00
'
    )
    File.expects(:exists?).with(builder_file_path).returns(true)
    provider.expects(:builder_file_path).twice.returns(builder_file_path)
    resources = provider.lookup_ring
    expect(resources['192.168.101.13:6002/1']).to_not be_nil
    expect(resources['192.168.101.14:6002/1']).to_not be_nil
    expect(resources['192.168.101.15:6002/1']).to_not be_nil

    expect(resources['192.168.101.13:6002/1'][:id]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:region]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:zone]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.13:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.13:6002/1'][:balance]).to eql '0.00'
    expect(resources['192.168.101.13:6002/1'][:meta]).to eql ''

    expect(resources['192.168.101.14:6002/1'][:id]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:region]).to eql '1'
    expect(resources['192.168.101.14:6002/1'][:zone]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.14:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.14:6002/1'][:balance]).to eql '0.00'
    expect(resources['192.168.101.14:6002/1'][:meta]).to eql ''
  end

  it 'should be able to lookup the local ring and build an object legacy' do
    provider_class.expects(:swift_ring_builder).returns(
'/etc/swift/object.builder, build version 3
262144 partitions, 3 replicas, 3 zones, 3 devices, 0.00 balance
The minimum number of hours before a partition can be reassigned is 1
Devices:    id  zone      ip address  port      name weight partitions balance meta
             2     2  192.168.101.14  6002         1   1.00     262144    0.00 
             0     3  192.168.101.15  6002         1   1.00     262144    0.00 
             1     1  192.168.101.13  6002         1   1.00     262144    0.00 
'
    )
    File.expects(:exists?).with(builder_file_path).returns(true)
    provider.expects(:builder_file_path).twice.returns(builder_file_path)
    resources = provider.lookup_ring
    expect(resources['192.168.101.15:6002/1']).to_not be_nil
    expect(resources['192.168.101.13:6002/1']).to_not be_nil
    expect(resources['192.168.101.14:6002/1']).to_not be_nil

    expect(resources['192.168.101.13:6002/1'][:id]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:region]).to eql 'none'
    expect(resources['192.168.101.13:6002/1'][:zone]).to eql '1'
    expect(resources['192.168.101.13:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.13:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.13:6002/1'][:balance]).to eql '0.00'
    expect(resources['192.168.101.13:6002/1'][:meta]).to eql ''

    expect(resources['192.168.101.14:6002/1'][:id]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:region]).to eql 'none'
    expect(resources['192.168.101.14:6002/1'][:zone]).to eql '2'
    expect(resources['192.168.101.14:6002/1'][:weight]).to eql '1.00'
    expect(resources['192.168.101.14:6002/1'][:partitions]).to eql '262144'
    expect(resources['192.168.101.14:6002/1'][:balance]).to eql '0.00'
    expect(resources['192.168.101.14:6002/1'][:meta]).to eql ''
  end
end
