require 'spec_helper'

require 'version'

describe OmnibusGitlabVersion do
  def version(version_string)
    described_class.new(version_string)
  end

  describe '#tag' do
    it { expect(version('1.2.3').tag).to eq('1.2.3+ce.0') }
    it { expect(version('1.2.3+ee').tag).to eq('1.2.3+ee.0') }
    it { expect(version('1.2.0+rc1').tag).to eq('1.2.0+rc1.ce.0') }
    it { expect(version('1.2.0+rc2.ee').tag).to eq('1.2.0+rc2.ee.0') }
    it { expect(version('wow.1').tag).to eq('0.0.0+ce.0') }
  end

  describe '#edition' do
    it 'returns ee when EE' do
      expect(version('8.3.2+ee').edition).to eq('ee')
    end

    it 'returns ce when not EE' do
      expect(version('8.3.2+ce').edition).to eq('ce')
    end

    it 'returns ce when not specified' do
      expect(version('8.3.2').edition).to eq('ce')
    end
  end

  describe '#ee?' do
    it 'returns true when EE' do
      expect(version('8.3.2+ee')).to be_ee
    end

    it 'returns false when not EE' do
      expect(version('8.3.2+ce')).not_to be_ee
    end

    it 'returns false when not specified' do
      expect(version('8.3.2')).not_to be_ee
    end
  end
end
