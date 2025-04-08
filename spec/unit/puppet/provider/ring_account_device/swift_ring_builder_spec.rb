require 'puppet'
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'lib', 'puppet', 'provider', 'ring_account_device', 'swift_ring_builder')
provider_class = Puppet::Type.type(:ring_account_device).provider(:swift_ring_builder)
describe provider_class do

  it "should have the SwiftRingBuilder provider class as its baseclass" do
    expect(provider_class.superclass).to equal(Puppet::Provider::SwiftRingBuilder)
  end

  let :builder_file_path do
    '/etc/swift/account.builder'
  end

   let :account_builder do
    Tempfile.new('account.builder')
   end

  let :provider do
    described_class.new(
      Puppet::Type.type(:ring_account_device).new(
        :name     => '192.168.101.13:6002/1',
        :zone     => '1',
        :weight   => '1',
        :provider => :swift_ring_builder
      )
    )
  end

  let :account_builder_output do
'/etc/swift/account.builder, build version 3
262144 partitions, 3 replicas, 3 zones, 3 devices, 0.00 balance
The minimum number of hours before a partition can be reassigned is 1
The overload factor is 0.00% (0.000000)
Ring file /etc/swift/account.ring.gz is up-to-date
Devices:    id  region  zone    ip address:port       replic_ip:replic_port              name weight partitions balance meta
             1     1     1  192.168.101.13:6002         192.168.101.13:6002                 1   1.00     262144 0.00
             2     1     2  192.168.101.14:6002         192.168.101.14:6002                 1   1.00     262144 200.00  m2
             0     1     3  192.168.101.15:6002         192.168.101.15:6002                 1   1.00     262144-100.00  m2
             3     1     1  192.168.101.16:6002         192.168.101.16:6002                 1   1.00     262144-100.00
'
  end

  describe "with no storage policy_index set" do

    it 'account builder file should be account.builder when object name has no policy_index' do
      policy_index = provider.policy_index
      expect(provider.builder_file_path(policy_index)).to eq builder_file_path
    end

    it 'ring_account_device should exist when found in builder file' do
      allow(provider.class).to receive(:swift_ring_builder).and_return account_builder_output
      expect(File).to receive(:exist?).with(builder_file_path).and_return(true)
      expect(provider.exists?).to eq({:id=>"1", :region=>"1", :zone=>"1", :weight=>"1.00", :partitions=>"262144", :balance=>"0.00", :meta=>"", :policy_index=>''})
    end

    it 'should be able to lookup the local ring' do
      expect(File).to receive(:exist?).with(builder_file_path).and_return(true)
      expect(provider).to receive(:builder_file_path).twice.and_return(builder_file_path)
      expect(provider).to receive(:swift_ring_builder).and_return account_builder_output
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

  describe "with a storage policy_index set" do

    it 'ring_account_device should fail when object name has a policy_index' do
      expect {
      Puppet::Type.type(:ring_account_device).new(:name => "1:192.168.101.13:6002/1", :zone => '1', :weight => '1', :provider => :swift_ring_builder)}.to raise_error(Puppet::Error, /Policy_index is not supported on account device/)
    end
  end
end
