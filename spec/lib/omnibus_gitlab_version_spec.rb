require 'spec_helper'

require 'version'

describe OmnibusGitlabVersion do
  def version(version_string)
    described_class.new(version_string)
  end

  describe '#tag' do
    it { expect(version('1.2.3').tag).to eq('1.2.3.0') }
    it { expect(version('1.2.0+rc1').tag).to eq('1.2.0.rc1.0') }
    it { expect(version('1.2.0+rc2').tag).to eq('1.2.0.rc2.0') }
    it { expect(version('wow.1').tag).to eq('0.0.0.0') }
  end
  

  describe '#version' do        
    it 'returns false when not specified' do
      expect(version('8.3.2+rc1')).not_to be_ee
    end    

    it 'returns false when not specified' do
      expect(version('8.3.2')).not_to be_ee
    end
  end
end
