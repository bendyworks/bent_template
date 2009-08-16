ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

Cucumber::Rails.bypass_rescue

require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'
require 'cucumber/webrat/table_locator' # Lets you do table.diff!(table_at('#my_table').to_a)

require File.expand_path(File.dirname(__FILE__) + '/../../spec/fixjour_builders')
World(Fixjour)

module ExcludeWatirByDefault
  cuke_opts = Cucumber::Cli::Main.step_mother.options
  if cuke_opts[:include_tags].empty? && cuke_opts[:exclude_tags].empty?
    cuke_opts[:exclude_tags] = ['watir']
    Cucumber::Cli::Main.step_mother.options = cuke_opts
  end

  if cuke_opts[:include_tags].include?('watir') || cuke_opts[:exclude_tags].include?('magic_watir')
    ENV['run_watir'] = 'true'

    # from: http://www.3hv.co.uk/blog/2009/01/16/cucumber-and-watir-kick-starting-your-testing/
    # system 'ruby script/server -p 3001 -e test -d'
    at_exit do
      puts "ack is better than grep. http://betterthangrep.com/" if %x[ack].include? 'command not found'
      system "kill `ps aux | ack 'ruby.*-p 3001' | ack -v ack | awk '{ print $2 }'`"
    end
  else
    # NOTE: webrat can be run with transactional fixtures.
    # Watir cannot because the server runs in a separate process from the watir tests.
    system 'rake db:test:prepare'
    Cucumber::Rails.use_transactional_fixtures
  end
end
World(ExcludeWatirByDefault)
