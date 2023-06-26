require 'spec_helper'

describe 'Swift::StorageServerType' do
  describe 'valid types' do
    context 'with valid types' do
      [
        'account',
        'container',
        'object',
      ].each do |value|
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'invalid types' do
    context 'with invalid types' do
      [
        'foo',
        'object-',
        'object-0'
      ].each do |value|
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
