require 'spec_helper'

describe 'swift::client' do

  describe "with default parameters" do
    it { should contain_package('swiftclient').with_ensure('present') }
  end

  describe "with specified version" do
    let :params do
      {:ensure => '2.0.2-1'}
    end

    it { should contain_package('swiftclient').with_ensure(params[:ensure]) }
  end
end
