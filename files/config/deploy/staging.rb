#############################################################
# Application
#############################################################

set :application, '#{project_name}'
set :deploy_to, "/var/web-other/#{application}/staging"

#############################################################
# Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :scm_verbose, true

set :rails_env, 'staging'

#############################################################
# Servers
#############################################################

set :user, 'deploy'
  raise "please set domain"
set :domain, '#{project_name}.bendyworks.com'
server domain, :app, :web
role :db, domain, :primary => true

#############################################################
# Git
#
# NOTE: Run ssh-keygen & put the contents of your .ssh/id_rsa.pub into ~deploy/.ssh/authorized_keys
# That way, we do not put a password here.
#############################################################

set :scm, :git
set :branch, 'master'
set :scm_user, 'deploy'
set :scm_passphrase, ''
  raise "please set repository"
set :repository, 'git@github.com:bendyworks/repo.git'
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

#############################################################
# Passenger
#############################################################

namespace :deploy do
  desc 'Create the database yaml file'
raise "please set DB credentials"
  task :after_update_code do
    db_config = <<-EOF

defaults: &defaults
  adapter: mysql
  host: localhost
  username: root
  password: password

staging:
  database: #{project_name}_staging
  <<: *defaults
EOF

    put db_config, "#{release_path}/config/database.yml"

    #########################################################
    # Uncomment the following to symlink an uploads directory.
    # Just change the paths to whatever you need.
    #########################################################

    # desc 'Symlink the upload directories'
    # task :before_symlink do
    #   run 'mkdir -p #{shared_path}/uploads'
    #   run 'ln -s #{shared_path}/uploads #{release_path}/public/uploads'
    # end
  end

  desc 'Populate the db with seed data'
  task :after_migrate do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "staging")

    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)
    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then current_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end

    run "cd #{directory}; #{rake} RAILS_ENV=#{rails_env} db:populate"
  end

  # Restart passenger on deploy
  desc 'Restarting mod_rails with restart.txt'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  cleanup
end
