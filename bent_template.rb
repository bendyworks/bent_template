#+ Rspec
#+ HAML/SASS
#+ Rspec Rails
#+ Cucumber
#+ Paperclip
#+ Fixjour
#+ Webrat
#+ Watir/SafariWatir/FireWatir
#+ Authlogic
#+ Hoptoad
#+ annotate_models
#+ html_matchers
#+ Capistrano
#+ Flog/Flay
#! Tarantula
#- tracker-git-hook
#+ rcov

project_name = File.basename(root)

load_template 'http://bendyworks.com/latest.rb'
GITHUB_USER = "bendyworks"

def bent_file path
  url = "http://github.com/#{GITHUB_USER}/bent_templates/raw/master/files/#{path}"
  file path, open(url).read
rescue OpenURI::HTTPError => e
  log "error", "retrieving #{url}, #{e.message}"
end

def mkdir folder
  FileUtils.mkdir_p(folder)
end

git :init

# PLUGINS
git :submodule => 'init'
# plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git', :submodule => true
# plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git', :submodule => true
# plugin 'haml', :git => 'git://github.com/nex3/haml.git', :submodule => true
# plugin 'cucumber', :git => 'git://github.com/aslakhellesoy/cucumber.git', :submodule => true
# plugin 'webrat', :git => 'git://github.com/brynary/webrat.git', :submodule => true
# plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git', :submodule => true
# plugin 'hoptoad', :git => 'git://github.com/thoughtbot/hoptoad_notifier.git', :submodule => true
# plugin 'db-populate', :git => 'git://github.com/ffmike/db-populate.git', :submodule => true
# plugin 'annotate_models', :git => 'git://github.com/bendycode/annotate_models', :submodule => true
# plugin 'html_matchers', :git => 'git://github.com/bendycode/html_matchers', :submodule => true

git :submodule => 'update'

# GEMS
gem 'binarylogic-authlogic', :lib => 'authlogic', :source => 'http://gems.github.com'

# GEMS FOR TESTING
gem 'fixjour', :env => 'test'
gem 'firewatir', :env => 'test'
gem 'safariwatir', :env => 'test'
gem 'flog', :env => 'test'
gem 'flay', :env => 'test'
gem 'relevance-rcov', :env => 'test', :lib => 'rcov', :source => 'http://gems.github.com'
gem 'remarkable_rails', :env => 'test'
# gem 'launchy', :env => 'test'

# TODO: fix tarantula setup
# gem 'relevance-tarantula', :env => 'test', :lib => 'relevance/tarantula', :source => 'http://gems.github.com'

rake 'gems:install', :sudo => true
rake 'gems:install', :sudo => true, :env => 'test'

# inside 'vendor/gems' do
#  run 'gem unpack tarantula'
# end
# rake 'tarantula:setup'

# GENERATORS
generate 'rspec'
generate 'cucumber'

# JQUERY
latest :jquery, :min
run 'curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js'

# TODO: AUTHLOGIC STUFF HERE
# generate authlogic
# create seed data for an admin user
# ensure "rake db:test:prepare" uses seed data

# DB-POPULATE
mkdir 'db/populate'



run 'rm README public/index.html public/favicon.ico'

bent_file 'config/database.yml.template'
# file 'config/database.yml.template', <<-END
# defaults: &defaults
#   adapter: mysql
#   host: localhost
#   username: root
#   password:
# 
# development:
#   database: #{project_name}_development 
#   <<: *defaults
# 
# test:
#   database: #{project_name}_test
#   <<: *defaults
# END

run 'cp config/database.yml.template config/database.yml'

rake 'db:create'
rake 'db:create', :env => 'test'
rake 'db:migrate'
rake 'db:test:prepare'

capify!
# setup capistrano-ext to point to config/deploy/[staging|production].rb

bent_file 'config/deploy.rb'

# file 'config/deploy.rb', 'set :stages, %w(staging production)
# require "capistrano/ext/multistage"
# 
# namespace :apache do
#   [:stop, :start, :restart, :reload].each do |action|
#     desc "#{action.to_s.capitalize} Apache"
#     task action, :roles => :web do
#       sudo "/etc/init.d/apache2 #{action.to_s}"
#     end
#   end
# end'

bent_file 'config/deploy/staging.rb'
bent_file 'config/deploy/production.rb'

append_file 'config/initializers/session_store.rb', 'ActionController::Base.session_store = :active_record_store'
rake 'db:sessions:create'

# TODO: create FourOhFourController and write a splat route for it
# TODO: remove default routes at bottom of routes.rb

gsub_file 'app/controllers/application_controller.rb', /#\s*(filter_parameter_logging :password)/, '\1'

# CUCUMBER

bent_file 'lib/tasks/change_default.rake'
bent_file 'lib/tasks/cucumber.rake'
# TODO: comment out two lines in 'lib/tasks/rspec.rake' that say "default"
bent_file 'Rakefile'
# TODO: add abandon to Rakefile
# TODO: append db:populate to db:test:prepare in Rakefile

bent_file 'spec/fixjour_builders.rb'
# file 'spec/fixjour_builders.rb', '
# require File.expand_path(File.dirname(__FILE__) + "/sequence")
# 
# # A_SEQUENCE = Sequence.new{|n| n.to_f }
# 
# Fixjour do
#   # define_builder(User) do |klass, overrides|
#   #   klass.new(:login => "admin", :email => "abc@def.com", :password => "password", :password_confirmation => "password")
#   # end
# end
# 
# def associated sym, overrides
#   klass = sym.to_s.pluralize.classify.constantize
#   overrides[sym] || klass.find_by_id(overrides["#{sym}_id".to_sym]) || self.send("new_#{sym}")
# end
# '

bent_file 'spec/lib/fixjour_builders_spec.rb'
# file 'spec/lib/fixjour_builders_spec.rb', <<-EOF
# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# describe 'Fixjour' do
#   it 'should have a working fixjour_builders.rb file' do
#     Fixjour.verify!
#   end
# end
# EOF

bent_file 'spec/sequence.rb'
# file 'spec/sequence.rb', <<-EOF
# class Sequence
#   attr_reader :proc
# 
#   def initialize (&proc) #:nodoc:
#     @proc  = proc
#     @value = 0
#   end
# 
#   # Returns the next value for this sequence
#   def next
#     @value += 1
#     @proc.call(@value)
#   end
# 
#   def current
#     @proc.call(@value)
#   end
#   alias_method :last, :current
# end
# EOF

# TODO: Add remarkable_rails and fixjour_builders (twice) to spec_helper.rb

bent_file 'cucumber.yml'
# file 'cucumber.yml', 'default: -r features/support/env.rb -r features/step_definitions -t ~disabled,~watir
# watir:   -r features/support/env.rb -r features/step_definitions -t watir,~disabled
# all_as_watir:     -r features/support/env.rb -r features/step_definitions -t ~magic_watir,~disabled'

mkdir 'features/expected_output_files'
mkdir 'features/input_files/data_files'
mkdir 'features/input_files/images'

bent_file 'features/step_definitions/helpers.rb'
# file 'features/step_definitions/helpers.rb', '
# def input_file *dir_and_file_names
#   path = dir_and_file_names.join "/"
#   relative_path("/../input_files/#{path}")
# end
# 
# def relative_path path
#   File.expand_path("#{File.dirname(__FILE__)}#{path}")
# end
# 
# def verify_table_contents table_selector, *dir_and_file_names
#   file_contents = File.read(expected_output_file("tables", dir_and_file_names))
#   expected = eval file_contents
#   response.should have_table(table_selector, expected)
# end
# 
# def expected_output_file *dir_and_file_names
#   path = dir_and_file_names.join "/"
#   relative_path("/../expected_output_files/#{path}")
# end'

bent_file 'features/step_definitions/steps.rb'
# file 'features/step_definitions/steps.rb', 'Given /^common data(.*$)/ do |modifier|
# end
# When /^I show page in browser$/ do
#   save_and_open_page
# end
# 
# Then /^I should see expected "([^\"]*)" table contents "([^\"]*)"$/ do |table_name, num|
#   verify_table_contents ".#{table_name}", "#{table_name}_#{num}"
# end
# 
# When /^I debug$/ do
#   debugger
#   x = 1
# end'

# TODO: watir steps gist
bent_file 'features/step_definitions/watir_steps.rb'
# TODO: update webrat_steps.rb to include if ENV['RUN_WATIR'] (etc)
bent_file 'features/support/bendycode.css'
bent_file 'features/support/bendycode.rb'
bent_file 'features/support/env.rb'
# TODO: add a generic path to paths.rb

# LIB
bent_file 'lib/label_form_builder.rb'
# file 'lib/label_form_builder.rb', 'class LabelFormBuilder < ActionView::Helpers::FormBuilder
#   helpers = field_helpers +
#     %w(date_select datetime_select time_select) +
#     %w(collection_select select country_select time_zone_select) -
#     %w(hidden_field label fields_for)
# 
#   helpers.each do |name|
#     define_method(name) do |field, *args|
#       options = args.last.is_a?(Hash) ? args.pop : {}
#       label_text = options.delete(:label)
#       label = label(field, label_text)
#       @template.content_tag(:p, label + \'<br/>\' + super)
#     end
#   end
# end'

mkdir 'public/stylesheets/sass'


bent_file '.gitignore'
# file '.gitignore', <<-END
# .DS_Store
# log/*.log
# tmp/**/*
# config/database.yml
# db/*.sqlite3
# END

git :add => '.'
git :config => 'branch.master.remote origin'
git :config => 'branch.master.merge refs/heads/master'
git :config => 'push.default matching'

run %{find . -type d -empty | grep -v 'vendor' | grep -v '.git' | grep -v 'tmp' | xargs -I xxx touch xxx/.gitignore}
git :add => '.'
git :commit => '-am "Initial commit as built by bent_templates"'
git :remote => "add origin git@bendyworks.com:${project_name}.git"
log 'TODO', "Update gitosis admin"
log 'TODO', "Execute `git push origin master:refs/heads/master`"
