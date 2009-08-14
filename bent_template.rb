
local_template = File.expand_path(File.join("~", ".bent_template"))

unless File.exists? local_template
  remote_template = "http://github.com/bendyworks/bent_templates/raw/master/dot_bent_template.rb"
  File.open(local_template, 'w') do |f|
    f.puts open(remote_template).read
  end
end