require 'spec_helper'

describe 'swift::proxy::tempurl' do

  let :facts do
    {}
  end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }'
  end

  it { is_expected.to contain_concat_fragment('swift-proxy-tempurl').with_content(/\[filter:tempurl\]\nuse = egg:swift#tempurl/) }

  ['methods',
   'incoming_remove_headers',
   'incoming_allow_headers',
   'outgoing_remove_headers',
   'outgoing_allow_headers' ].each do |h|
     it { is_expected.to_not contain_concat_fragment('swift-proxy-tempurl').with_content(/#{h}/) }
   end

   context "when params are set" do
     let :params do {
       'methods' => ['GET','HEAD','PUT'],
       'incoming_remove_headers' => ['x-foo','x-bar-*'],
       'incoming_allow_headers'  => ['x-foo','x-bar-*'],
       'outgoing_remove_headers' => ['x-foo','x-bar-*'],
       'outgoing_allow_headers'  => ['x-foo','x-bar-*'],
     } end

     it { is_expected.to contain_concat_fragment('swift-proxy-tempurl').with_content(/methods = GET HEAD PUT/) }
     ['incoming_remove_headers',
      'incoming_allow_headers',
      'outgoing_remove_headers',
      'outgoing_allow_headers' ].each do |h|
        it { is_expected.to contain_concat_fragment('swift-proxy-tempurl').with_content(/#{h} = x-foo x-bar-*/) }
      end

      describe 'when params are not array' do
        let :params do {
          'methods' => 'GET HEAD PUT',
          'incoming_remove_headers' => 'x-foo x-bar-*',
          'incoming_allow_headers'  => 'x-foo x-bar-*',
          'outgoing_remove_headers' => 'x-foo x-bar-*',
          'outgoing_allow_headers'  => 'x-foo x-bar-*',
        } end

        it { is_expected.to contain_concat_fragment('swift-proxy-tempurl').with_content(/methods = GET HEAD PUT/) }
        ['incoming_remove_headers',
         'incoming_allow_headers',
         'outgoing_remove_headers',
         'outgoing_allow_headers' ].each do |h|
           it { is_expected.to contain_concat_fragment('swift-proxy-tempurl').with_content(/#{h} = x-foo x-bar-*/) }
         end
      end
   end
end
