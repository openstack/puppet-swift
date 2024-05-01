require 'spec_helper'

describe 'Swift::MountDevice' do
  describe 'valid types' do
    context 'with valid types' do
      [
        '/dev',
        '/dev/sda',
        '/opt/swift/diskfile',
        'LABEL=foo'
      ].each do |value|
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'invalid types' do
    context 'with invalid types' do
      [
        1,
        true,
        {},
        ['/dev/sda'],
        'dev',
        'dev/sda',
        'LABEL=',
        'LABELfoo'
      ].each do |value|
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
