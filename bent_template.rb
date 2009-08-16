
project_name = File.basename(root)
load_template 'http://bendyworks.com/latest.rb'

GITHUB_USER = "bendyworks"

def bent_file path
  url = "http://github.com/#{GITHUB_USER}/bent_templates/raw/master/files/#{path}"
  file path, open(url).read.gsub('#{project_name}', project_name)
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

# TODO: create FourOhFourController and write a splat route for it
# TODO: remove default routes at bottom of routes.rb

gsub_file 'app/controllers/application_controller.rb', /#\s*(filter_parameter_logging :password)/, '\1'

# CUCUMBER

bent_file 'lib/tasks/change_default.rake'
bent_file 'lib/tasks/cucumber.rake'
# TODO: comment out two lines in 'lib/tasks/rspec.rake' that say "default"
bent_file 'Rakefile'

bent_file 'spec/fixjour_builders.rb'
bent_file 'spec/lib/fixjour_builders_spec.rb'
bent_file 'spec/sequence.rb'

# TODO: Add remarkable_rails and fixjour_builders (twice) to spec_helper.rb

bent_file 'cucumber.yml'

mkdir 'features/expected_output_files'
mkdir 'features/input_files/data_files'
mkdir 'features/input_files/images'

bent_file 'features/step_definitions/helpers.rb'
bent_file 'features/step_definitions/steps.rb'
bent_file 'features/step_definitions/watir_steps.rb'

# TODO: update webrat_steps.rb to include if ENV['RUN_WATIR'] (etc)
bent_file 'features/support/bendycode.css'
bent_file 'features/support/bendycode.rb'
bent_file 'features/support/env.rb'
# TODO: add a generic path to paths.rb

# LIB
bent_file 'lib/label_form_builder.rb'

mkdir 'public/stylesheets/sass'
run 'rm README public/index.html public/favicon.ico'

bent_file '.gitignore'

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
