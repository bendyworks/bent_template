
local_bent = File.expand_path(File.join("~", ".bent"))

unless File.exists? local_bent
  remote_template = "http://github.com/bendyworks/bent_templates/raw/master/dot_bent.rb"
  File.open(local_bent, 'w') do |f|
    f.puts open(remote_template).read
  end
end