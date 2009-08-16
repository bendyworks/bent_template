$LOAD_PATH.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib') if File.directory?(RAILS_ROOT + '/vendor/plugins/cucumber/lib')

unless ARGV.any? {|a| a =~ /^gems/}
  begin
    require 'cucumber/rake/task'

    Cucumber::Rake::Task.new(:features) do |t|
      t.fork = true # Explicitly fork

      chosen_format = if ENV['CC_BUILD_ARTIFACTS']
        "html -o '#{ENV['CC_BUILD_ARTIFACTS']}/features.html'"
      else
        'progress'
      end

      t.cucumber_opts = "--strict --format #{chosen_format} -p default"
    end

    Cucumber::Rake::Task.new(:watir) do |t|
      t.fork = true # Explicitly fork

      chosen_format = if ENV['CC_BUILD_ARTIFACTS']
        "html -o '#{ENV['CC_BUILD_ARTIFACTS']}/features.html'"
      else
        'progress'
      end

      t.cucumber_opts = "--strict --format #{chosen_format} -p watir"
    end

    task :cucumber => ['features', 'watir']

    Cucumber::Rake::Task.new(:watir_all) do |t|
      t.fork = true # Explicitly fork

      chosen_format = if ENV['CC_BUILD_ARTIFACTS']
        "html -o '#{ENV['CC_BUILD_ARTIFACTS']}/features.html'"
      else
        'progress'
      end

      t.cucumber_opts = "--strict --format #{chosen_format} -p all_as_watir"
    end

    task :features => 'db:test:prepare'
  rescue LoadError
    desc 'Cucumber rake task not available'
    task :features do
      abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
    end
  end
end