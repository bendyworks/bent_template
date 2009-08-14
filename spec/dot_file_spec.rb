require File.expand_path(File.join(__FILE__, '..', 'helpers'))

describe "bent_templates" do
  describe "install on a fresh system" do
    before do
      @dot_bent_path = File.expand_path(File.join("~", ".bent"))
      File.delete(@dot_bent_path) if File.exists?(@dot_bent_path)
      @dummy_app = 'dummy_app'
      FileUtils.rm_r @dummy_app unless Dir[@dummy_app].empty?
    end

    it "creates a new dot_file from github" do
      bent_template_path = find_template
      system "rails #{@dummy_app} -m #{bent_template_path} &> /dev/null"

      File.exists?(@dot_bent_path).should be_true
      File.read(@dot_bent_path).strip.should == last_pushed_dot_file_contents
    end
  end

  describe "git handling" do
    it "sets up git repository" do
      bent_template_path = find_template(:local)
      system "rails #{@dummy_app} -m #{bent_template_path} &> /dev/null"

      # dummy_app/.git directory exists
      # git init
      # write .gitignore file
      # git add .
      # git ci -m ''
      # git remote add origin blah
      # git submodule add <each plugin defined as git_submodule>
      # git submodule
      # git push
      # make sure some random .gitignored file is not under git control
    end
  end
end