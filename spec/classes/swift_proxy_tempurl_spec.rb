require 'spec_helper'

describe 'swift::proxy::tempurl' do

  let :facts do
    {}
  end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }'
  end

  let :fragment_file do
    "/var/lib/puppet/concat/_etc_swift_proxy-server.conf/fragments/29_swift-proxy-tempurl"
  end

  it { is_expected.to contain_file(fragment_file).with_content(/[filter:tempurl]/) }
  it { is_expected.to contain_file(fragment_file).with_content(/use = egg:swift#tempurl/) }

  ['methods',
   'incoming_remove_headers',
   'incoming_allow_headers',
   'outgoing_remove_headers',
   'outgoing_allow_headers' ].each do |h|
     it { is_expected.to_not contain_file(fragment_file).with_content(/#{h}/) }
   end

   context "when params are set" do
     let :params do {
       'methods' => ['GET','HEAD','PUT'],
       'incoming_remove_headers' => ['x-foo','x-bar-*'],
       'incoming_allow_headers'  => ['x-foo','x-bar-*'],
       'outgoing_remove_headers' => ['x-foo','x-bar-*'],
       'outgoing_allow_headers'  => ['x-foo','x-bar-*'],
     } end

     it { is_expected.to contain_file(fragment_file).with_content(/methods = GET HEAD PUT/) }
     ['incoming_remove_headers',
      'incoming_allow_headers',
      'outgoing_remove_headers',
      'outgoing_allow_headers' ].each do |h|
        it { is_expected.to contain_file(fragment_file).with_content(/#{h} = x-foo x-bar-*/) }
      end

      describe 'when params are not array' do
        let :params do {
          'methods' => 'GET HEAD PUT',
          'incoming_remove_headers' => 'x-foo x-bar-*',
          'incoming_allow_headers'  => 'x-foo x-bar-*',
          'outgoing_remove_headers' => 'x-foo x-bar-*',
          'outgoing_allow_headers'  => 'x-foo x-bar-*',
        } end

        it { is_expected.to contain_file(fragment_file).with_content(/methods = GET HEAD PUT/) }
        ['incoming_remove_headers',
         'incoming_allow_headers',
         'outgoing_remove_headers',
         'outgoing_allow_headers' ].each do |h|
           it { is_expected.to contain_file(fragment_file).with_content(/#{h} = x-foo x-bar-*/) }
         end
      end
   end
end
