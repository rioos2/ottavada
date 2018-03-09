require_relative 'base_release'
require_relative '../omnibus_gitlab_version'
require_relative '../project/omnibus_gitlab'
require 'time'

module Release
  class OmnibusGitlabRelease < BaseRelease
    class VersionFileDoesNotExistError < StandardError; end
    class TemplateFileDoesNotExistError < StandardError; end
    class VersionStringNotFoundError < StandardError; end
    class SecurityReleaseInProgressError < StandardError; end

    # Number of minutes we will be able to reuse the same security repository.
    SECURITY_REPO_GRACE_PERIOD = 24 * 60 * 60

    private    

    def before_execute_hook     
      super
    end

    def after_release
      bump_container_versions(stable_branch)
      bump_container_versions('master')
      push_ref('branch', stable_branch)
      push_ref('branch', 'master')

      super
    end

    def repo_variable
      return @repo_variable if defined?(@repo_variable)
    end

    def security_repository
      @security_repository ||= "security-#{Time.now.utc.strftime('%Y%m%dT%H%MZ')}"
    end

    def release_in_progress?(repo_variable)
      return false unless repo_variable

      time_limit = repo_variable_time(repo_variable) + SECURITY_REPO_GRACE_PERIOD

      Time.now.utc > time_limit
    end

    def repo_variable_time(repo_variable)
      Time.parse(repo_variable.split('-').last)
    end
   

    def remotes
      Project::OmnibusGitlab.remotes(dev_only: options[:security])
    end

    def version_class
      OmnibusGitlabVersion
    end

    def bump_versions
      version_files.each do |file|
        bump_version(file, version_from_gitlab_repo(file))
      end
    end

    def version_files
      files = %w[GITLAB_SHELL_VERSION GITLAB_WORKHORSE_VERSION]
      files << 'GITLAB_PAGES_VERSION' if expect_pages_version_file?
      files << 'GITALY_SERVER_VERSION' if expect_gitaly_version_file?
      files << 'VERSION' # Always update VERSION last
      files
    end

    # GitLab pages was released in EE 8.3, and CE 8.17
    def expect_pages_version_file?
      if version.ee?
        version.major > 8 || version.major == 8 && version.minor > 4
      else
        version.major > 8 || version.major == 8 && version.minor > 16
      end
    end

    def expect_gitaly_version_file?
      version.major >= 9
    end

    def version_from_gitlab_repo(file_name)
      file_path = File.join(repository.path, file_name)
      unless File.exist?(file_path)
        raise VersionFileDoesNotExistError.new(file_path)
      end

      read_file_from_gitlab_repo(file_name)
    end

    def read_file_from_gitlab_repo(file_name)
      gitlab_file_path = File.join(options[:gitlab_repo_path], file_name)
      unless File.exist?(gitlab_file_path)
        raise VersionFileDoesNotExistError.new(gitlab_file_path)
      end

      File.read(gitlab_file_path).strip
    end

    def bump_container_versions(branch)
      repository.ensure_branch_exists(branch)
    end

    def version_from_container_template(file_path)
      unless File.exist?(file_path)
        raise TemplateFileDoesNotExistError.new(file_path)
      end

      file_version = File.open(file_path) { |f| f.read.match(%r{gitlab/gitlab-ce:(\d+\.\d+\.\d+-ce\.\d+)})[1] }
      version_class.new(file_version.tr('-', '+'))
    end
 
  end
end
