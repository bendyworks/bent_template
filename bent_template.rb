PROJECT_NAME = File.basename(root)
load_template 'http://bendyworks.com/latest.rb'

GITHUB_USER = "bendyworks"

def bent_file path
  url = "http://github.com/#{GITHUB_USER}/bent_templates/raw/master/files/#{path}"
  file path, open(url).read.gsub('#{project_name}', PROJECT_NAME)
rescue OpenURI::HTTPError => e
  log "error", "retrieving #{url}, #{e.message}"
end

def comment_out path, line
  gsub_file path, /^(\s*)(#{Regexp.escape(line)})/, '\1# \2'
end

def uncomment path, line
  gsub_file path, /#\s*(#{Regexp.escape(line)})/, '\1'
end

def insert_after path, target, to_insert
  gsub_file path, /(^.*#{Regexp.escape(target)}.*$)/, "\\1\n\n#{to_insert}\n"
end

def insert_before path, target, to_insert
  gsub_file path, /(^.*#{Regexp.escape(target)}.*$)/, "#{to_insert}\n\n\\1\n"
end

def mkdir folder
  FileUtils.mkdir_p(folder)
end

git :init

# PLUGINS
git :submodule => 'init'
plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git', :submodule => true
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git', :submodule => true
plugin 'haml', :git => 'git://github.com/nex3/haml.git', :submodule => true
plugin 'cucumber', :git => 'git://github.com/aslakhellesoy/cucumber.git', :submodule => true
plugin 'webrat', :git => 'git://github.com/brynary/webrat.git', :submodule => true
plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git', :submodule => true
plugin 'hoptoad', :git => 'git://github.com/thoughtbot/hoptoad_notifier.git', :submodule => true
plugin 'db-populate', :git => 'git://github.com/ffmike/db-populate.git', :submodule => true
plugin 'annotate_models', :git => 'git://github.com/bendycode/annotate_models', :submodule => true
plugin 'html_matchers', :git => 'git://github.com/bendycode/html_matchers', :submodule => true

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
# gem 'launchy', :env => 'test' # have not used yet. plan to try

# TODO: fix tarantula setup. this is broken
# gem 'relevance-tarantula', :env => 'test', :lib => 'relevance/tarantula', :source => 'http://gems.github.com'

rake 'gems:install', :sudo => true
rake 'gems:install', :sudo => true, :env => 'test'

# FIXME:
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

bent_file 'config/database.yml.template'

run 'cp config/database.yml.template config/database.yml'

rake 'db:create'
rake 'db:create', :env => 'test'
rake 'db:migrate'
rake 'db:test:prepare'

capify!

bent_file 'config/deploy.rb'
bent_file 'config/deploy/staging.rb'
bent_file 'config/deploy/production.rb'

append_file 'config/initializers/session_store.rb', 'ActionController::Base.session_store = :active_record_store'
rake 'db:sessions:create'

comment_out 'config/routes.rb', "map.connect ':controller/:action/:id"

# TODO: create FourOhFourController and write a splat route for it
# gsub_file 'config/routes.rb', /^end$/,
#   "  unless ::ActionController::Base.consider_all_requests_local
#     map.connect '*path', :controller => 'application', :action => 'rescue_404'
#   end
# end"

uncomment 'app/controllers/application_controller.rb', 'filter_parameter_logging :password'

# CUCUMBER
bent_file 'lib/tasks/change_default.rake'
bent_file 'lib/tasks/cucumber.rake'
comment_out 'lib/tasks/rspec.rake', "Rake.application.instance_variable_get('@tasks').delete('default')"
comment_out 'lib/tasks/rspec.rake', "task :default => :spec"
bent_file 'Rakefile'

bent_file 'spec/fixjour_builders.rb'
bent_file 'spec/lib/fixjour_builders_spec.rb'
bent_file 'spec/sequence.rb'

insert_after 'spec/spec_helper.rb', "require 'spec/rails'",
  "require 'remarkable_rails'\nrequire File.expand_path(File.dirname(__FILE__) + \"/fixjour_builders\")"
insert_after 'spec/spec_helper.rb', "# config.fixture_path = RAILS_ROOT + '/spec/fixtures/'",
  "  config.include(Fixjour)"

bent_file 'cucumber.yml'

mkdir 'features/expected_output_files'
mkdir 'features/input_files/data_files'
mkdir 'features/input_files/images'

bent_file 'features/step_definitions/helpers.rb'
bent_file 'features/step_definitions/steps.rb'
bent_file 'features/step_definitions/watir_steps.rb'

webrat_steps = 'features/step_definitions/webrat_steps.rb'
gsub_file webrat_steps, /^(.+)$/, '  \1'
insert_before webrat_steps,
  'require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))',
  "unless ENV['run_watir']"
append_file webrat_steps, "\nend"

bent_file 'features/support/bendycode.css'
bent_file 'features/support/bendycode.rb'
bent_file 'features/support/env.rb'

insert_before 'features/support/paths.rb', '# Add more mappings here.', '    when /the (.*) page/
      "/#{$1.gsub(/\s/, \'_\').underscore}"'

# LIB
bent_file 'lib/label_form_builder.rb'

mkdir 'public/stylesheets/sass'
run 'rm README public/index.html public/favicon.ico'

bent_file '.gitignore'

rake 'db:migrate'

git :add => '.'
git :config => 'branch.master.remote origin'
git :config => 'branch.master.merge refs/heads/master'
git :config => 'push.default matching'

run %{find . -type d -empty | grep -v 'vendor' | grep -v '.git' | grep -v 'tmp' | xargs -I xxx touch xxx/.gitignore}
git :add => '.'
git :commit => '-am "Initial commit as built by bent_templates"'
# git :remote => "add origin git@github.com:#{GITHUB_USER}/#{PROJECT_NAME}.git"
log 'TODO', "git add origin git@github.com:YOUR_GITHUB_USERNAME/#{PROJECT_NAME}.git"
log 'TODO', "Tell github about your repo"
log 'TODO', "Execute `git push`"
