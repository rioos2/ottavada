require_relative 'base_release'
require_relative '../project/omnibus_gitlab'
require 'time'

module Release
  class OmnibusGitlabRelease < BaseRelease
   
    private    

    def before_execute_hook     
      super
    end  

 
    def remotes
      Project::OmnibusGitlab.remotes(dev_only: options[:security])
    end

 
  end
end