require 'rubygems'
require 'grit'
require 'yaml'
require File.expand_path(File.join(__FILE__, '..', 'helpers'))

describe "bent_templates" do
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
  end

  describe "install on a fresh system" do
    before do
      File.delete(@dot_bent_path) if File.exists?(@dot_bent_path)
    end

    it "creates a new dot_file from github" do
      run_rails true

      File.exists?(@dot_bent_path).should be_true
      File.read(@dot_bent_path).strip.should == last_pushed_dot_file_contents
    end
  end
end