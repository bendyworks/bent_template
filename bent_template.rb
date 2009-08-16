
local_bent = File.expand_path(File.join("~", ".bent"))

unless File.exists? local_bent
  @remote_template ||= "http://github.com/bendyworks/bent_templates/raw/master/dot_bent.rb"
  File.open(local_bent, 'w') do |f|
    f.puts open(@remote_template).read
  end
end

@feature_location = {}
if defined?(::FEATURES_FOR_TESTING)
  FEATURES_FOR_TESTING.each do |feature, path|
    @feature_location[feature] = path
    load_template @feature_location[feature]
  end
else
  ['git', 'rspec'].each do |feature|
    @feature_location[feature] =
      "http://github.com/bendyworks/bent_templates/raw/master/actions/#{feature}_init.rb"
    load_template @feature_location[feature]
  end
end

load_template local_bent
