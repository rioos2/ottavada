require_relative 'base_project'

module Project
  class Rioos < BaseProject
    REMOTES = {      
      gitlab: 'git@gitlab.com:rioos/nilavu.git',   
    }.freeze

    def self.path
      "#{group}/nilavu"
    end
  end
end
