#! /usr/bin/env ruby
##
## Unit testing for the swiftinit service provider
##

require 'spec_helper'

provider_class = Puppet::Type.type(:service).provider(:swiftinit)

describe provider_class do


  before(:each) do
    # Create a mock resource
    @resource = stub 'resource'

    @provider = provider_class.new

    # A catch all; no parameters set
    allow(@resource).to receive(:[]).and_return(nil)

    # But set name, source and path
    allow(@resource).to receive(:[]).with(:name).and_return "swift-object-server"
    allow(@resource).to receive(:[]).with(:ensure).and_return :enable
    allow(@resource).to receive(:[]).with(:pattern).and_return "swift-object"
    allow(@resource).to receive(:[]).with(:manifest).and_return "object-server"
    allow(@resource).to receive(:ref).and_return "Service[myservice]"

    @provider.resource = @resource

    allow(@provider).to receive(:command).with(:systemctl_run).and_return "systemctl_run"

    allow(@provider).to receive(:systemctl_run)

  end

  it "should have a status method" do
    expect(@provider).to respond_to(:status)
  end

  it "should have a start method" do
    expect(@provider).to respond_to(:start)
  end

  it "should have a stop method" do
    expect(@provider).to respond_to(:stop)
  end

  it "should have a restart method" do
    expect(@provider).to respond_to(:restart)
  end

  it "should have a refresh method" do
    expect(@provider).to respond_to(:refresh)
  end

  it "should have an enabled? method" do
    expect(@provider).to respond_to(:enabled?)
  end

  it "should have an enable method" do
    expect(@provider).to respond_to(:enable)
  end

  it "should have a disable method" do
    expect(@provider).to respond_to(:disable)
  end

end

#####  TODO figure out how to stub out files and test each method more.
