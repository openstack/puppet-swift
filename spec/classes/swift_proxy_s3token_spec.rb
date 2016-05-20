require 'spec_helper'

describe 'swift::proxy::s3token' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_s3token').with_content('
[filter:s3token]
paste.filter_factory = keystonemiddleware.s3_token:filter_factory
auth_port = 35357
auth_protocol = http
auth_host = 127.0.0.1
')
    end
  end

  describe "when overriding default parameters" do
    let :params do
      {
          :auth_port     => 4212,
          :auth_protocol => 'https',
          :auth_host     => '1.2.3.4'
      }
    end
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_s3token').with_content(/auth_port = 4212/)
      is_expected.to contain_concat_fragment('swift_s3token').with_content(/auth_protocol = https/)
      is_expected.to contain_concat_fragment('swift_s3token').with_content(/auth_host = 1.2.3.4/)
    end
  end

end
