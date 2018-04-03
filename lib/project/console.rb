require_relative 'base_project'

module Project
  class Console < BaseProject
    REMOTES = {
      gitlab: 'git@gitlab.com:rioos/relconsole.git',
    }.freeze

    def self.path
      "#{group}/relconsole"
    end
  end
end
