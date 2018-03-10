require 'spec_helper'
require 'rugged'

require 'release/rioos_release'

describe Release::RioosRelease, :silence_stdout do
  include RuggedMatchers

  # NOTE (rspeicher): There is some "magic" here that can be confusing.
  #
  # The release process checks out a remote to `/tmp/some_folder`, where
  # `some_folder` is based on the last part of a remote path, excluding `.git`.
  #
  # So `https://gitlab.com/foo/bar/repository.git` gets checked out to
  # `/tmp/repository`, and `/this/project/spec/fixtures/repositories/release`
  # gets checked out to `/tmp/release`.
  let(:repo_path)    { File.join('/tmp', ReleaseFixture.repository_name) }
  let(:ob_repo_path) { File.join('/tmp', OmnibusReleaseFixture.repository_name) }

  # These two Rugged repositories are used for _verifying the result_ of the
  # release run. Not to be confused with the fixture repositories.
  let(:repository)    { Rugged::Repository.new(repo_path) }
  let(:ob_repository) { Rugged::Repository.new(ob_repo_path) }

  before do
    fixture    = ReleaseFixture.new
    ob_fixture = OmnibusReleaseFixture.new

    fixture.rebuild_fixture!
    ob_fixture.rebuild_fixture!

    # Disable cleanup so that we can see what's the state of the temp Git repos
    allow_any_instance_of(RemoteRepository).to receive(:cleanup).and_return(true)

    # Override the actual remotes with our local fixture repositories
    allow_any_instance_of(described_class).to receive(:remotes)
      .and_return({ gitlab: "file://#{fixture.fixture_path}" })
    allow_any_instance_of(Release::OmnibusGitlabRelease).to receive(:remotes)
      .and_return({ gitlab: "file://#{ob_fixture.fixture_path}" })
  end

  after do
    # Manually perform the cleanup we disabled in the `before` block
    FileUtils.rm_rf(repo_path,    secure: true) if File.exist?(repo_path)
    FileUtils.rm_rf(ob_repo_path, secure: true) if File.exist?(ob_repo_path)
  end

  def execute(version, branch)
    described_class.new(version).execute
    repository.checkout(branch)
    ob_repository.checkout(branch)
  end

  describe '#execute' do
    let(:changelog_manager) { double(release: true) }

    before do
      allow(Changelog::Manager).to receive(:new).with(repo_path).and_return(changelog_manager)
    end

      context "with a new 10-1-stable} stable branch, releasing an RC" do
        let(:version)        { "10.1.0-rc13" }
        let(:ob_version)     { "10.1.0+rc13.0" }
        let(:docker_version) { "gitlab/gitlab-ce:#{ob_version.tr('+', '-')}" }
        let(:branch)         { "10-1-stable" }

        describe "release Rio/OS" do
          it 'does not perform changelog compilation' do
            expect(Changelog::Manager).not_to receive(:new)

            execute(version, branch)
          end

          it 'creates a new branch and updates the version in VERSION, and creates a new branch, a new tag and updates the version files in the omnibus-gitlab repo' do
            execute(version, branch)

            aggregate_failures do

              # GitLab expectations
              expect(repository.head.name).to eq "refs/heads/#{branch}"
              expect(repository).to have_version.at(version)

              # Omnibus-GitLab expectations
              expect(ob_repository.head.name).to eq "refs/heads/#{branch}"
              expect(ob_repository.tags[ob_version]).to be_nil
              expect(ob_repository).to have_version.at(version)
              expect(ob_repository).to have_version('aran').at('2.3.0')
              expect(ob_repository).to have_version('nilavu').at('3.4.0')
              expect(ob_repository).to have_version('beedi').at('5.6.0')
            end
          end
        end
      end

      context "with a new 10-1-stable stable branch, releasing a stable .0" do
        let(:version)        { "10.1.0" }
        let(:ob_version)     { "10.1.0.0" }
        let(:docker_version) { "gitlab/gitlab-ce:#{ob_version.tr('+', '-')}" }
        let(:branch)         { "10-1-stable" }

        describe "release Rio/OS" do
          it 'performs changelog compilation' do
            expect(changelog_manager).to receive(:release).with(version)

            execute(version, branch)
          end

          it 'creates a new branch and updates the version in VERSION, and creates a new branch, a new tag and updates the version files in the omnibus-gitlab repo' do
            execute(version, branch)

            aggregate_failures do
              # GitLab expectations
              expect(repository.head.name).to eq "refs/heads/#{branch}"
              expect(repository).to have_version.at(version)

              repository.checkout('master')

              expect(repository).to have_version.at('10.2.0-pre')
              expect(repository.tags['v10.2.0.pre']).not_to be_nil
              

              # Omnibus-GitLab expectations
              expect(ob_repository.head.name).to eq "refs/heads/#{branch}"
              expect(ob_repository.tags[ob_version]).to be_nil
              expect(ob_repository).to have_version.at(version)
              expect(ob_repository).to have_version('aran').at('2.3.0')
              expect(ob_repository).to have_version('nilavu').at('3.4.0')
              expect(ob_repository).to have_version('beedi').at('5.6.0')
              
            end
          end
        end
      end

  end
end