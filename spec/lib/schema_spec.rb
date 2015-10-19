describe WepaExtractor::Schema do
  let(:type) { 'text' }
  let(:schema_items) { [] }
  let(:subject) { WepaExtractor::Schema.new(type, schema_items) }

  describe '#as_json' do
    it 'returns type key' do
      expect(subject.as_json[:type]).to eq 'text'
    end

    it 'delegates as_json on each item in schema_items array' do
      i1 = double('schema_item1', as_json: 1)
      i2 = double('schema_item2', as_json: 2)
      subject = WepaExtractor::Schema.new(type, [i1, i2])
      expect(subject.as_json[:schema_items]).to eq [1, 2]
    end
  end

  describe '#to_yaml' do
    it 'converts result of as_json' do
      mocked_result = { mocked: true }
      expect(subject).to receive(:as_json).and_return(mocked_result)
      expect(subject.to_yaml).to eq YAML.dump(mocked_result)
    end
  end

  describe '#call' do
    it 'iterate over items'
    it 'use prepare_document'
    it 'merge_up items store in parent document (not in inner_schema)'
  end

  describe '#prepare_document' do
    it 'keeps \'html\' type as is' do
      input = 'any data'
      subject = WepaExtractor::Schema.new('html', [])
      expect(subject.prepare_document(input)).to eq input
    end

    it 'parse text and returns Nokogiri::HTML::Document when type is text' do
      expect(subject.prepare_document('')).to be_a(Nokogiri::HTML::Document)
    end

    context 'when type is url' do
      it 'read and parse to Nokogiri::HTML::Document' do
        subject = WepaExtractor::Schema.new('url', [])
        input = 'http://otevrenebrno.cz'
        expect(subject).to receive(:open).and_return('')
        expect(subject.prepare_document(input)).to be_a(Nokogiri::HTML::Document)
      end

      it 'set correctly url on returned document' do
        subject = WepaExtractor::Schema.new('url', [])
        input = 'http://otevrenebrno.cz'
        expect(subject).to receive(:open).and_return('<html></html>')
        expect(subject.prepare_document(input).url).to eq input
      end
    end
  end
end
