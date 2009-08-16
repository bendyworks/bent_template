
local_bent = File.expand_path(File.join("~", ".bent"))

unless File.exists? local_bent
  @remote_template ||= "http://github.com/bendyworks/bent_templates/raw/master/dot_bent.rb"
  File.open(local_bent, 'w') do |f|
    f.puts open(@remote_template).read
  end
end

@feature_location = {}
['git', 'rspec'].each do |feature|
  if defined?(::FEATURES_FOR_TESTING)
    @feature_location[feature] = FEATURES_FOR_TESTING[feature]
  else
    @feature_location[feature] =
      "http://github.com/bendyworks/bent_templates/raw/master/#{feature}/#{feature}_init.rb"
  end

  load_template @feature_location[feature]
end

load_template local_bent