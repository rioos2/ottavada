def get_version(args)
  version = Version.new(args[:version])

  unless version.valid?
    $stdout.puts "Version number must be in the following format: X.Y.Z-rc1 or X.Y.Z".colorize(:red)
    exit 1
  end

  version
end

def dry_run?
  SharedStatus.dry_run?
end

def force?
  ENV['FORCE'].present?
end

def skip?(repo)
  ENV[repo.upcase] == 'false'
end

def no_mention?
  ENV['NO_MENTION'].present?
end
