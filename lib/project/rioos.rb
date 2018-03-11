require_relative 'base_project'

module Project
  class Rioos < BaseProject
    REMOTES = {      
      gitlab: 'git@gitlab.com:rioos/aran.git',   
    }.freeze

    def self.path
      "#{group}/aran"
    end
  end
end
