require 'spec_helper'
describe 'device_hiera' do

  context 'with defaults for all parameters' do
    it { should contain_class('device_hiera') }
  end
end
