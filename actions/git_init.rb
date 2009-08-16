# run git_bent twice. once at the beginning, once at the end
def git_bent
  git_bent_generic do
    remote_repo = File.basename(root)
    git "remote add origin git@#{GIT_SERVER}:#{remote_repo}.git"
    # git 'push origin master' # must set up github repo first
    # git 'push origin master:refs/heads/master' # This is for future use with gitosis
  end
end

def github_bent
  github_login = %x[git config --global github.user].strip
  github_token = %x[git config --global github.token].strip
  project_name = File.basename(root)

  git_bent_generic do
    remote_repo = "#{github_login}/#{project_name}"
    git "remote add origin git@github.com:#{remote_repo}.git"

    unless defined?(FEATURES_FOR_TESTING) # GitHub disallows deleting and recreating, so can't test
      post_params = {
        :login => github_login,
        :token => github_token,
        :name => project_name,
      }.map {|k, v| "-F '#{k}=#{v}'"}.join(' ')

      run "curl #{post_params} http://github.com/api/v2/yaml/repos/create"
      git 'push origin master'
    end
  end
end

# DO NOT CALL THIS FROM A .bent FILE
def git_bent_generic
  in_root do
    if Dir['.git'].empty?
      git 'init'
      file '.gitignore', <<GITIGNORE
**/.DS_Store
.DS_Store
log/*.log
tmp/**/*
tmp/*
config/database.yml
db/*.sqlite3
*.tmproj
public/system
features/support/bendycode.*
tmp/sass-cache
GITIGNORE
    else
      git 'add .'
      git 'commit -m "Initial bent_templates commit"'

      remote_repo = File.basename(root)
      yield
    end
  end
end