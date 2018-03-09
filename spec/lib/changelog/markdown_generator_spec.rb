require 'spec_helper'

require 'changelog/markdown_generator'
require 'version'

describe Changelog::MarkdownGenerator do
  describe 'initialize' do
    it 'only accepts valid entries' do
      entries = [
        double(valid?: false),
        double(valid?: true),
        double(valid?: false)
      ]

      generator = described_class.new(double, entries)

      expect(generator.entries.length).to eq(1)
    end
  end

  describe '#to_s' do
    it 'includes the version header' do
      version = Version.new('1.2.3')
      generator = described_class.new(version, [])

      expect(generator.to_s).to match(/^## 1\.2\.3/)
    end

    it 'includes group headers' do
      entries = [
        double(id: 1, to_s: 'Change A', type: 'security', valid?: true, author: 'user'),
        double(id: 2, to_s: 'Change B', type: 'fixed',    valid?: true, author: 'user'),
        double(id: 3, to_s: 'Change C', type: 'added',    valid?: true, author: 'user')
      ]

      version = Version.new('1.2.3')
      generator = described_class.new(version, entries)

      Timecop.freeze(Time.local(2017, 12, 31))

      expected = <<-EOF.strip_heredoc
        ## 1.2.3 (2017-12-31)

        ### Security (1 change, 1 of them is from the community)

        - Change A

        ### Fixed (1 change, 1 of them is from the community)

        - Change B

        ### Added (1 change, 1 of them is from the community)

        - Change C


      EOF

      expect(generator.to_s).to eq(expected)
    end

    describe 'includes the date in the version header' do
      it 'uses `Release.next_date` for monthly releases' do
        version = Version.new('9.2.0')
        generator = described_class.new(version, [])

        Timecop.freeze(Time.local(1983, 7, 18))

        expect(generator.to_s).to match(/\(1983-07-22\)$/)
      end

      it 'uses the current date for all other releases' do
        version = Version.new('1.2.3')
        generator = described_class.new(version, [])

        Timecop.freeze(Time.local(1983, 7, 2))

        expect(generator.to_s).to match(/\(1983-07-02\)$/)
      end
    end

    it 'sorts entries by type in `Changelog::Entry::TYPES` and by their entry ID in ascending order' do
      entries = [
        double(id: 5, to_s: "Change A", type: 'security', valid?: true, author: 'user'),
        double(id: 3, to_s: "Change B", type: 'security', valid?: true, author: 'user'),
        double(id: 1, to_s: "Change C", type: 'fixed',    valid?: true, author: 'user')
      ]
      markdown = described_class.new(spy, entries).to_s

      expect(markdown).to match(/- Change B\n- Change A\n[\n\s\d#()a-zA-Z,]*- Change C/)
    end

    it 'sorts entries without an ID last' do
      entries = [
        double(id: 5,   to_s: 'Change A', valid?: true, type: 'fixed', author: 'user'),
        double(id: nil, to_s: 'Change B', valid?: true, type: 'fixed', author: 'user'),
        double(id: 1,   to_s: 'Change C', valid?: true, type: 'fixed', author: 'user')
      ]
      markdown = described_class.new(spy, entries).to_s

      expect(markdown).to match("- Change C\n- Change A\n- Change B\n")
    end

    it 'handles a non-numeric ID comparison' do
      entries = [
        double(id: 5,     to_s: 'Change A', valid?: true, type: 'fixed', author: 'user'),
        double(id: 'foo', to_s: 'Change B', valid?: true, type: 'fixed', author: 'user'),
        double(id: 1,     to_s: 'Change C', valid?: true, type: 'fixed', author: 'user')
      ]
      generator = described_class.new(spy, entries)

      markdown = generator.to_s

      expect(markdown).to match("- Change B\n- Change C\n- Change A\n")
    end

    it 'adds a "No changes" entry when there are no entries' do
      version = Version.new('1.2.3')
      generator = described_class.new(version, [])

      markdown = generator.to_s

      expect(markdown).to match("- No changes.\n")
    end
  end
end
