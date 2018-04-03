require_relative 'base_project'

module Project
  class OmnibusGitlab < BaseProject
    REMOTES = {
      gitlab: 'git@gitlab.com:rioos/relpoochi.git',
    }.freeze

    def self.path
      "#{group}/poochi"
    end
  end
end
