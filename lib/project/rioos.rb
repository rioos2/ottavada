require_relative 'base_project'

module Project
  class Rioos < BaseProject
    REMOTES = {      
      gitlab: 'git@gitlab.com:rioos/relaran.git',   
    }.freeze

    def self.path
      "#{group}/relaran"
    end
  end
end
