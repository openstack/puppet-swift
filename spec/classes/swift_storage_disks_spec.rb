# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
require 'spec_helper'

describe 'swift::storage::disks' do

  shared_examples_for 'swift storage disks' do
    let :params do
      {
        :args => {
          'sdb' => {
            'byte_size' => '2048',
          },
          'sdc' => {
          },
        },
      }
    end

    it {
      is_expected.to contain_swift__storage__disk('sdb').with(
        :byte_size => '2048')
      is_expected.to contain_swift__storage__disk('sdc')
    }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'swift storage disks'
    end
  end

end
