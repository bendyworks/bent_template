set :stages, %w(staging production)
# set :default_stage, "staging" # I'd rather be explicit for now...

# Chose not to freeze capistrano-ext into the vendor/gems directory.
# Just make sure you:     gem install capistrano-ext
# require File.expand_path("#{File.dirname(__FILE__)}/../vendor/gems/capistrano-ext/lib/capistrano/ext/multistage")
require 'capistrano/ext/multistage'

namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      sudo "/etc/init.d/apache2 #{action.to_s}"
    end
  end
end