require 'spec_helper'
require 'project/rioos'

describe Project::Rioos do
  it_behaves_like 'project #remotes'

  describe '.path' do
    it { expect(described_class.path).to eq 'rioos/aran' }
  end
end
