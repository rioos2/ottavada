require 'spec_helper'

require 'changelog'
require 'changelog/manager'
require 'version'

describe Changelog::Manager do
  include RuggedMatchers

  let(:fixture)    { File.expand_path('../../fixtures/repositories/changelog', __dir__) }
  let(:repository) { Rugged::Repository.new(fixture) }
  let(:config)     { Changelog::Config }

  describe 'initialize' do
    before do
      reset_fixture!
    end

    it 'accepts a path String' do
      manager = described_class.new(fixture)

      expect(manager.repository).to be_kind_of(Rugged::Repository)
    end

    it 'accepts a Rugged::Repository object' do
      manager = described_class.new(repository)

      expect(manager.repository).to eq repository
    end

    it 'raises an error for any other object' do
      expect { described_class.new(StringIO.new) }.to raise_error(RuntimeError)
    end
  end

  describe '#release', 'for CE' do
    let(:version) { Version.new('8.10.5') }

    let(:master) { repository.branches['master'] }
    let(:stable) { repository.branches[version.stable_branch] }

    before do
      reset_fixture!

      described_class.new(repository).release(version)
    end

    it 'updates the changelog file' do
      expect(master.target).to have_modified(config.ce_log)
      expect(stable.target).to have_modified(config.ce_log)
    end

    it 'removes only the changelog files picked into stable' do
      picked   = File.join(config.ce_path, 'fix-cycle-analytics-commits.yml')
      unpicked = File.join(config.ce_path, 'group-specific-lfs.yml')

      aggregate_failures do
        expect(master.target).to have_deleted(picked)
        expect(repository).to have_blob(unpicked).for('master')

        expect(stable.target).to have_deleted(picked)
        expect(stable.target).not_to have_deleted(unpicked)
        expect(repository).not_to have_blob(unpicked).for(version.stable_branch)
      end
    end

    it 'adds a sensible commit message' do
      message = "Update #{config.ce_log} for #{version}\n\n[ci skip]"

      aggregate_failures do
        expect(master.target.message).to eq(message)
        expect(stable.target.message).to eq(message)
      end
    end
  end  

  describe '#release', 'with no changelog entries' do
    let(:version) { Version.new('8.2.1') }

    let(:master) { repository.branches['master'] }
    let(:stable) { repository.branches[version.stable_branch] }

    before do
      reset_fixture!

      described_class.new(repository).release(version)
    end

    it 'gracefully does nothing' do
      unpicked1 = File.join(config.ce_path, 'fix-cycle-analytics-commits.yml')
      unpicked2 = File.join(config.ce_path, 'group-specific-lfs.yml')

      aggregate_failures do
        expect(repository).to have_blob(unpicked1).for('master')
        expect(repository).to have_blob(unpicked2).for('master')
        expect(repository).to have_blob(config.ce_log).for('master')
      end
    end
  end

  describe '#release', 'with CE entries but no EE entries' do
    let(:version) { Version.new('8.3.1') }

    let(:master) { repository.branches['master'] }
    let(:stable) { repository.branches[version.stable_branch] }

    let(:ce_master_commit) { master.target }
    let(:ce_stable_commit) { stable.target }
    let(:ee_master_commit) { ce_master_commit.parents.first }
    let(:ee_stable_commit) { ce_stable_commit.parents.first }

    before do
      reset_fixture!

      described_class.new(repository).release(version)
    end

    it 'updates both changelog files' do
      aggregate_failures do
        expect(read_head_blob(repository, config.ce_log))
          .not_to match('No changes')       
      end
    end
  end

  describe '#release', 'with no changelog blob' do
    it 'raises NoChangelogError' do
      allow(Changelog::Config).to receive(:log).and_return('CHANGELOG-FOO.md')

      reset_fixture!

      expect { described_class.new(repository).release(Version.new('8.10.5')) }
        .to raise_error(Changelog::NoChangelogError)
    end
  end

  def reset_fixture!
    ChangelogFixture.new.rebuild_fixture!
  end
end
