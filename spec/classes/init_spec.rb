require 'spec_helper'
describe 'linux_cis' do
  context 'with default values for all parameters' do
    it { should contain_class('linux_cis') }
  end
end
