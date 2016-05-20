#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
# Tests for swift::proxy::container_quotas
#

require 'spec_helper'

describe 'swift::proxy::container_quotas' do

  let :facts do
    {}
  end

  it { is_expected.to contain_concat_fragment('swift_container_quotas').with_content(/\[filter:container_quotas\]/) }
  it { is_expected.to contain_concat_fragment('swift_container_quotas').with_content(/use = egg:swift#container_quotas/) }

end
