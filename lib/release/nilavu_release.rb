require_relative 'rioos_release'
require_relative '../project/nilavu'

module Release
  class NilavuRelease < RioosRelease
    private

    def remotes
      Project::Nilavu.remotes(dev_only: options[:security])
    end

    def after_execute_hook
    	true
    end

  end
end
