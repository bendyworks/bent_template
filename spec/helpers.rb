def find_template source = :remote
  file_name = (source == :remote) ? 'bent_template.rb' : 'spec/bent_template_for_testing.rb'

  ["..", "."].each do |dir|
    full_path = File.expand_path("#{dir}/#{file_name}")
    return full_path if File.exists? full_path
  end
  raise "#{file_name} not found"
end

def last_pushed_dot_file_contents
  require 'grit'
  repo = Grit::Repo.new File.expand_path('.')
  blobs = repo.commits('origin/master').first.tree.contents
  dbt = blobs.select {|b| b.name == 'dot_bent_template.rb'}.first
  dbt.data
end