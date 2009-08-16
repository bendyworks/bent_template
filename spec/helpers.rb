def run_rails remote = false
  if remote
    env = ''
  else
    env = 'DOT_BENT="dot_bent.rb"'
  end
  # system "#{env} rails #{@dummy_app} -m #{find_template}"
  require 'rails/version'
  require 'rails_generator'
  require 'rails_generator/scripts/generate'
  Rails::Generator::Base.use_application_sources!
  Rails::Generator::Scripts::Generate.new.run([@dummy_app, '-m', find_template], :generator => 'app')
end

def find_template
  file_name = 'bent_template.rb'

  ["..", "."].each do |dir|
    full_path = File.expand_path("#{dir}/#{file_name}")
    return full_path if File.exists? full_path
  end
  raise "#{file_name} not found"
end

def last_pushed_dot_file_contents
  repo = Grit::Repo.new File.expand_path('.')
  blobs = repo.commits('origin/master').first.tree.contents
  dbt = blobs.select {|b| b.name == 'dot_bent.rb'}.first
  dbt.data
end

def dir_exists name
  Dir[File.expand_path("./#{@dummy_app}/#{name}")].should_not be_empty
end

def file_exists name, contents = nil
  path = "./#{@dummy_app}/#{name}"
  File.exists?(path).should be_true
  File.read(path).should == contents if contents
end

def verify_submodule path
  submodule = Grit::Repo.new("./#{@dummy_app}/#{path}")
  app = Grit::Repo.new("./#{@dummy_app}")
  submodule.commits.should_not == app.commits
end