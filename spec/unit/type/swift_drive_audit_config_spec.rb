require 'puppet'
require 'puppet/type/swift_drive_audit_config'

describe 'Puppet::Type.type(:swift_drive_audit_config)' do
  before :each do
    @swift_drive_audit_config = Puppet::Type.type(:swift_drive_audit_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'swift::install::end')
    catalog.add_resource anchor, @swift_drive_audit_config
    dependency = @swift_drive_audit_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@swift_drive_audit_config)
    expect(dependency[0].source).to eq(anchor)
  end

end
