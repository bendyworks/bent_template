
local_template = File.expand_path(File.join("~", ".bent_template"))
unless File.exists? local_template
  # file File.expand_path(File.join("~", ".bent_template")), "f" # open("http://github.com/bendyworks/bent_templates/raw/master/dot_bent_template.rb").read
  File.open(local_template, 'w') do |f|
    f.puts 'f'
  end
end