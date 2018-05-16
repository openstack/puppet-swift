require 'spec_helper'

describe 'swift::proxy::tempurl' do
  shared_examples 'swift::proxy::tempurl' do
    it { is_expected.to contain_swift_proxy_config('filter:tempurl/use').with_value('egg:swift#tempurl') }

    ['methods',
     'incoming_remove_headers',
     'incoming_allow_headers',
     'outgoing_remove_headers',
     'outgoing_allow_headers' ].each do |h|
       it { is_expected.to_not contain_swift_proxy_config("filter:tempurl/#{h}").with_value('') }
     end

     context "when params are set" do
       let :params do {
         'methods' => ['GET','HEAD','PUT'],
         'incoming_remove_headers' => ['x-foo','x-bar-*'],
         'incoming_allow_headers'  => ['x-foo','x-bar-*'],
         'outgoing_remove_headers' => ['x-foo','x-bar-*'],
         'outgoing_allow_headers'  => ['x-foo','x-bar-*'],
       } end

       it { is_expected.to contain_swift_proxy_config('filter:tempurl/methods').with_value('GET HEAD PUT') }
       ['incoming_remove_headers',
        'incoming_allow_headers',
        'outgoing_remove_headers',
        'outgoing_allow_headers' ].each do |h|
          it { is_expected.to contain_swift_proxy_config("filter:tempurl/#{h}").with_value('x-foo x-bar-*') }
        end

        describe 'when params are not array' do
          let :params do {
            'methods' => 'GET HEAD PUT',
            'incoming_remove_headers' => 'x-foo x-bar-*',
            'incoming_allow_headers'  => 'x-foo x-bar-*',
            'outgoing_remove_headers' => 'x-foo x-bar-*',
            'outgoing_allow_headers'  => 'x-foo x-bar-*',
          } end

          it { is_expected.to contain_swift_proxy_config('filter:tempurl/methods').with_value('GET HEAD PUT') }
          ['incoming_remove_headers',
           'incoming_allow_headers',
           'outgoing_remove_headers',
           'outgoing_allow_headers' ].each do |h|
             it { is_expected.to contain_swift_proxy_config("filter:tempurl/#{h}").with_value('x-foo x-bar-*') }
           end
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

      it_configures 'swift::proxy::tempurl'
    end
  end
end
