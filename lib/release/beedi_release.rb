require_relative 'rioos_release'
require_relative '../project/beedi'

module Release
  class BeediRelease < RioosRelease
    private

    def remotes
      Project::Beedi.remotes(dev_only: options[:security])
    end
  end
end
