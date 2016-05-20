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
# Tests for swift::proxy::account_quotas
#

require 'spec_helper'

describe 'swift::proxy::account_quotas' do

  it do
    is_expected.to contain_concat_fragment('swift_account_quotas').with_content("\n[filter:account_quotas]\nuse = egg:swift#account_quotas\n")
  end
end
