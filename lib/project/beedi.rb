require_relative 'base_project'

module Project
  class Beedi < BaseProject
    REMOTES = {
      gitlab: 'git@gitlab.com:rioos/beedi.git',
    }.freeze

    def self.path
      "#{group}/beedi"
    end
  end
end
