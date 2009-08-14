def find_template
  ['../bent_template.rb', './bent_template.rb'].each do |path|
    full_path = File.expand_path(path)
    return full_path if File.exists? full_path
  end
  raise "bent_template.rb not found"
end

def last_pushed_dot_file_contents
  require 'grit'
  repo = Grit::Repo.new File.expand_path('.')
end

describe "install" do
  describe "on a fresh system" do
    before do
      @dot_file_path = File.expand_path(File.join("~", ".bent_template"))
      File.delete(@dot_file_path) if File.exists?(@dot_file_path)

      @dummy_app = 'dummy_app'
      FileUtils.rm_r @dummy_app unless Dir[@dummy_app].empty?
    end

    it "creates a new dot_file from github" do
      bent_template_path = find_template

      system "rails #{@dummy_app} -m #{bent_template_path} &> /dev/null"

      File.exists?(@dot_file_path).should be_true
      File.read(@dot_file_path).should == "git\n"
    end
  end
end