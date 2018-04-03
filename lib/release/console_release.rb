require_relative 'rioos_release'
require_relative '../project/console'

module Release
  class ConsoleRelease < RioosRelease
    private

    def remotes
      Project::Console.remotes(dev_only: options[:security])
    end

    def after_execute_hook
    	true
    end
  end
end
