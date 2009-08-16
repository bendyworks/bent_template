require 'rubygems'
require 'grit'
require File.expand_path(File.join(__FILE__, '..', 'helpers'))

describe "rspec handling" do
  before(:all) do
    @dot_bent_path = File.expand_path(File.join("~", ".bent"))
    FileUtils.cp @dot_bent_path, "#{@dot_bent_path}.bak"
  end
  after(:all) do
    FileUtils.mv "#{@dot_bent_path}.bak", @dot_bent_path
  end

  before do
    @dummy_app = 'dummy_app'
    FileUtils.rm_r @dummy_app unless Dir[@dummy_app].empty?
    feature_location = {}
    ['git', 'rspec'].each do |feature|
      feature_location[feature] =
        File.expand_path(File.join(__FILE__, '..', '..', 'actions', "#{feature}_init.rb"))
    end
    FEATURES_FOR_TESTING = feature_location
    File.open(File.expand_path(File.join('~', '.bent')), 'w') do |f|
      f.puts "git_bent"
      f.puts "rspec_bent"
    end
  end
  it "sets up rspec" do
    run_rails

    dir_exists "vendor/plugins/rspec"
    verify_submodule "vendor/plugins/rspec"
  end
end