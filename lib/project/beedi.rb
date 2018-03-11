require_relative 'base_project'

module Project
  class Beedi < BaseProject
    REMOTES = {      
      gitlab: 'git@gitlab.com:rioos/relbeedi.git',   
    }.freeze

    def self.path
      "#{group}/relbeedi"
    end
  end
end
