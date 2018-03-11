require_relative 'base_project'

module Project
  class Nilavu < BaseProject
    REMOTES = {      
      gitlab: 'git@gitlab.com:rioos/relnilavu.git',   
    }.freeze

    def self.path
      "#{group}/relnilavu"
    end
  end
end
