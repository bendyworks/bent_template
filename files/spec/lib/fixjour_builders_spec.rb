require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Fixjour' do
  it 'should have a working fixjour_builders.rb file' do
    Fixjour.verify!
  end
end