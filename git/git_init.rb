# run git_bent twice. once at the beginning, once at the end
def git_bent
  in_root do
    if Dir['.git'].empty?
      git 'init'
      file '.gitignore', 'log'
    else
      git 'add .'
      git 'commit -m "First commit"'

      remote_repo = File.basename(root)
      remote_repo = "#{GITHUB_LOGIN}/#{File.basename(root)}" if defined?(GITHUB_LOGIN)
      git "remote add origin git@#{GIT_SERVER}:#{remote_repo}.git"
      # git 'push origin master' # must set up github repo first
      # git 'push origin master:refs/heads/master' # This is for future use with gitosis
    end
  end
end
