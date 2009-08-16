task :default => :test

Rake::Task[:test].abandon

desc 'Run all tests on this project'
task :test do
  tasks = %w(spec features)
  # tasks << 'spec:performance' if ENV['CC_BUILD_ARTIFACTS']
  tasks << 'watir' unless ENV['CC_BUILD_ARTIFACTS']

  errors = tasks.collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact

  if(out = ENV['CC_BUILD_ARTIFACTS'])
    unless(Dir['coverage'].empty?)
      mv('coverage', out)
    end
  end

  abort "Errors running #{errors.to_sentence}!" if errors.any?

  # if(out = ENV['CC_BUILD_ARTIFACTS'])
  #   mv('doc/models.png', out)
  # end
end
