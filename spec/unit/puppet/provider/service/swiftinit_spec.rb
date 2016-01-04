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
    @resource.stubs(:[]).returns(nil)

    # But set name, source and path
    @resource.stubs(:[]).with(:name).returns "swift-object-server"
    @resource.stubs(:[]).with(:ensure).returns :enable
    @resource.stubs(:[]).with(:pattern).returns "swift-object"
    @resource.stubs(:[]).with(:manifest).returns "object-server"
    @resource.stubs(:ref).returns "Service[myservice]"

    @provider.resource = @resource

    @provider.stubs(:command).with(:systemctl_run).returns "systemctl_run"

    @provider.stubs(:systemctl_run)

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
