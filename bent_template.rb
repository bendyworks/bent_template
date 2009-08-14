
local_bent = File.expand_path(File.join("~", ".bent"))

unless File.exists? local_bent
  remote_template = ENV['DOT_BENT'] || "http://github.com/bendyworks/bent_templates/raw/master/dot_bent.rb"
  File.open(local_bent, 'w') do |f|
    f.puts open(remote_template).read
  end
end

['git', 'rspec'].each do |feature|
  feature_location = "http://github.com/bendyworks/bent_templates/raw/master/#{feature}/#{feature}_init.rb"
  load_template feature_location
end

load_template local_bent