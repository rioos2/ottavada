require_relative 'version'

class OmnibusGitlabVersion < Version
  VERSION_REGEX = %r{
    \A(?<major>\d+)
    \.(?<minor>\d+)
    (\.(?<patch>\d+))?
    (\+)?
    (?<rc>rc(?<rc_number>\d*))?    
    (\.\d+)?\z
  }x

  def tag
    str = "#{to_patch}."
    str << "rc#{rc}." if rc?
    str << '0'
  end
end
