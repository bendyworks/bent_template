def run_rails remote = false
  if remote
    env = ''
  else
    env = 'DOT_BENT="dot_bent.rb"'
  end
  system "#{env} rails #{@dummy_app} -m #{find_template}"
end

def find_template
  file_name = 'bent_template.rb'

  ["..", "."].each do |dir|
    full_path = File.expand_path("#{dir}/#{file_name}")
    return full_path if File.exists? full_path
  end
  raise "#{file_name} not found"
end

def last_pushed_dot_file_contents
  repo = Grit::Repo.new File.expand_path('.')
  blobs = repo.commits('origin/master').first.tree.contents
  dbt = blobs.select {|b| b.name == 'dot_bent.rb'}.first
  dbt.data
end