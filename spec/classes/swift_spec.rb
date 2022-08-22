require 'spec_helper'

describe 'swift' do
  shared_examples 'swift' do
    let :params do
      {
        :swift_hash_path_suffix => 'string',
      }
    end

    context 'when no swift hash is specified' do
      let :params do
        {}
      end

      it 'should raise an exception' do
        expect { catalogue }.to raise_error(Puppet::Error)
      end
    end

    context 'when using defaults' do
      it 'should configure swift.conf' do
        is_expected.to contain_swift_config(
          'swift-hash/swift_hash_path_suffix').with_value('string')
        is_expected.to contain_swift_config(
          'swift-hash/swift_hash_path_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config(
          'swift-constraints/max_header_size').with_value(8192)
      end

      it {
        is_expected.to contain_package('swift').with_ensure('present')
        is_expected.to contain_package('swift').that_requires('Anchor[swift::install::begin]')
        is_expected.to contain_package('swift').that_notifies('Anchor[swift::install::end]')
      }
    end

    context 'when overriding package_ensure parameter' do
      before do
        params.merge!({:package_ensure => '1.12.0-1'})
      end

      it 'should effect ensure state of swift package' do
        is_expected.to contain_package('swift').with_ensure(params[:package_ensure])
      end
    end

    context 'with max_header_size' do
      before do
        params.merge!({:max_header_size => 16384})
      end

      it 'should configure swift.conf' do
        is_expected.to contain_swift_config(
          'swift-constraints/max_header_size').with_value(16384)
      end
    end

    context 'with only swift_hash_path_prefix' do
      let :params do
        { :swift_hash_path_prefix => 'string' }
      end

      it 'should configure swift.conf' do
        is_expected.to contain_swift_config(
          'swift-hash/swift_hash_path_suffix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config(
          'swift-hash/swift_hash_path_prefix').with_value('string')
      end
    end

    context 'when providing swift_hash_path_prefix and swift_hash_path_suffix' do
      let (:params) do
        {
          :swift_hash_path_suffix => 'mysuffix',
          :swift_hash_path_prefix => 'myprefix'
        }
      end

      it 'should configure swift.conf' do
        is_expected.to contain_swift_config(
          'swift-hash/swift_hash_path_suffix').with_value('mysuffix')
        is_expected.to contain_swift_config(
          'swift-hash/swift_hash_path_prefix').with_value('myprefix')
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift'
    end
  end
end
