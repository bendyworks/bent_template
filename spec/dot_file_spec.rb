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

  describe "github handling" do
    before do
      File.open(File.expand_path(File.join('~', '.bent')), 'w') do |f|
        f.puts File.read(File.expand_path(File.join(__FILE__, '..', '..', 'dot_bent.rb')))
      end

      # GitHub disallows recreating a repo. boo.
      #
      # github_login = %x[git config --global github.user].strip
      # github_token = %x[git config --global github.token].strip
      # project_name = @dummy_app
      # post_params = {
      #   :login => github_login,
      #   :token => github_token,
      # }.map {|k, v| "-F '#{k}=#{v}'"}.join(' ')
      # yaml = YAML::parse(%x[curl #{post_params} http://github.com/api/v2/yaml/repos/delete/#{project_name}])
      # 
      # post_params = {
      #   :login => github_login,
      #   :token => github_token,
      #   :delete_token => yaml['delete_token'].value,
      # }.map {|k, v| "-F '#{k}=#{v}'"}.join(' ')
      # system "curl #{post_params} http://github.com/api/v2/yaml/repos/delete/#{project_name}"
    end
    it "sets up github repository" do
      pending "testing github integration is hard because they don't allow deleting, then recreating"
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
      repo.commits.size.should == 1
      repo.commits.first.message.should == 'Initial bent_templates commit'
    end
  end
end