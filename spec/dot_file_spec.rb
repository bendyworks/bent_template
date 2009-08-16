require 'rubygems'

require 'grit'
require File.expand_path(File.join(__FILE__, '..', 'helpers'))

describe "bent_templates" do
  before do
    @dot_bent_path = File.expand_path(File.join("~", ".bent"))
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

  describe "git handling" do
    before do
      File.open(File.expand_path(File.join('~', '.bent')), 'w') do |f|
        f.puts File.read(File.expand_path(File.join(__FILE__, '..', '..', 'dot_bent.rb')))
      end
    end
    it "sets up git repository" do
      @feature_location = {}
      ['git', 'rspec'].each do |feature|
        @feature_location[feature] =
          File.expand_path(File.join(__FILE__, '..', '..', feature, "#{feature}_init.rb"))
      end
      FEATURES_FOR_TESTING = @feature_location
      run_rails

      Dir[File.expand_path("./#{@dummy_app}/.git")].should_not be_empty

      File.exists?("./#{@dummy_app}/.gitignore").should be_true
      File.read("./#{@dummy_app}/.gitignore").should include("log")
      repo = Grit::Repo.new("./#{@dummy_app}")
      repo.tree.contents.should_not be_empty
      repo.commits.should_not be_empty
      # git ci -m ''
      # git remote add origin blah
      # git submodule add <each plugin defined as git_submodule>
      # git submodule
      # git push
    end
  end
end