describe WepaExtractor::Schema::Item do
  let(:key)   { WepaExtractor::Matcher::Const.new('key') }
  let(:value) { WepaExtractor::Matcher::Const.new('value') }
  let(:subject) { WepaExtractor::Schema::Item.new(key, value) }

  let(:parent_key) { WepaExtractor::Matcher::Const.new('^') }

  describe '#as_json' do
    it 'returns key and value' do
      expect(subject.as_json[:key]).to eq(key.as_json)
      expect(subject.as_json[:value]).to eq(value.as_json)
    end

    it 'returns inner_schema if given' do
      expect(subject.as_json[:inner_schema]).to be nil

      nested_schmea = double('nested schema', as_json: { nested: true })
      upper_schema = WepaExtractor::Schema::Item.new(
        key, value, inner_schema: nested_schmea
      )
      expect(upper_schema.as_json[:inner_schema]).to eq nested_schmea.as_json
    end

    it 'returns non-default custom options' do
      # all options except key and value are default in subject
      expect(subject.as_json.keys).to eq [:key, :value]

      s = WepaExtractor::Schema::Item.new(key, value, multi: true)
      expect(s.as_json[:multi]).to be true

      s = WepaExtractor::Schema::Item.new(key, value, debug: true)
      expect(s.as_json[:debug]).to be true

      s = WepaExtractor::Schema::Item.new(key, value, merge_array: true)
      expect(s.as_json[:merge_array]).to be true
    end
  end

  it '#to_s' do
    expect(subject.to_s).to eq 'Item(#<Const:"key">, #<Const:"value">, {})'

    nested_schmea = double('nested schema')
    upper_schema = WepaExtractor::Schema::Item.new(
      key, value, inner_schema: nested_schmea
    )
    expect(upper_schema.to_s).to eq(
      'Item(#<Const:"key">, #<Const:"value">, {:inner_schema=>"#[Double \"nested schema\"]"})'
    )
  end

  describe 'merge_up?' do
    it 'returns true if key is Const class and equal to ^' do
      schema = WepaExtractor::Schema::Item.new(parent_key, value)
      expect(schema.merge_up?).to be true
    end

    it 'returns false when key is not Const' do
      css_key = WepaExtractor::Matcher::Css.new('^')
      schema = WepaExtractor::Schema::Item.new(css_key, value)
      expect(schema.merge_up?).to be false
    end

    it 'returns false when key not eq to ^' do
      expect(subject.merge_up?).to be false
    end
  end

  describe '#extract_key' do
    let(:key) { double('KeyMatcher', call: key_result) }
    let(:subject) { WepaExtractor::Schema::Item.new(key, value) }

    context 'key_matcher returns String' do
      let(:key_result) { 'String result' }
      it 'forwards key_matcher result as result' do
        expect(subject.extract_key('input')).to eq key_result
      end
    end

    context 'key_matcher returns one item (in Array)' do
      let(:key_result) { ['String result'] }
      it 'returns the item' do
        expect(subject.extract_key('input')).to eq key_result.first
      end
    end

    context 'key_matcher returns empty resutls (as Array)' do
      let(:key_result) { [] }
      it 'raises exception' do
        expect do
          subject.extract_key('input')
        end.to raise_exception /Non-atomic match.*found 0 result/
      end
    end

    context 'key_matcher returns several resutls (as Array)' do
      let(:key_result) { [1, 2, 3] }
      it 'raises exception' do
        expect do
          subject.extract_key('input')
        end.to raise_exception /Non-atomic match.*found 3 result/
      end
    end
  end

  describe 'extract_value' do
    let(:value) { double('ValueMatcher', call: value_result) }

    context 'opition multi is false' do
      let(:subject) { WepaExtractor::Schema::Item.new(key, value) }
      context 'value_matcher returns String' do
        let(:value_result) { 'String result' }
        it 'forwards key_matcher result as result' do
          expect(subject.extract_value('input')).to eq value_result
        end

        context 'when inner_schema is present' do
          let(:value_result) { 'String result' }
          it 'calls inner_schema' do
            nested_schmea = double('nested schema')

            item = WepaExtractor::Schema::Item.new(
              key,
              value,
              inner_schema: nested_schmea
            )

            expect(nested_schmea).to(
              receive(:call).with(value_result).and_return 'Yeh!'
            )

            expect(item.extract_value('input')).to eq 'Yeh!'
          end
        end
      end

      context 'key_matcher returns one item (in Array)' do
        let(:value_result) { ['String result'] }
        it 'returns the item' do
          expect(subject.extract_value('input')).to eq value_result.first
        end
      end

      context 'key_matcher returns empty resutls (as Array)' do
        let(:value_result) { [] }
        it 'raises exception' do
          expect do
            subject.extract_value('input')
          end.to raise_exception /Non-atomic match.*found 0 result/
        end
      end

      context 'key_matcher returns several resutls (as Array)' do
        let(:value_result) { %w(1 2 3) }
        it 'raises exception' do
          expect do
            subject.extract_value('input')
          end.to raise_exception /Non-atomic match.*found 3 result/
        end
      end
    end

    context 'option muliti is true' do
      let(:node) { double('Node', text: 'text node') }
      let(:value_result) { ['1', node] }
      let(:subject) { WepaExtractor::Schema::Item.new(key, value, multi: true) }
      it 'returns array of results' do
        expect(subject.extract_value('input')).to eq ['1', node.text]
      end
    end

    context 'option multi=true, merge_array=true' do
      let(:node1) { double('Node', text: { n1: 1 }) }
      let(:node2) { double('Node', text: { n2: 2 }) }
      let(:value_result) { [node1, node2] }
      let(:subject) { WepaExtractor::Schema::Item.new(key, value, multi: true, merge_array: true) }
      it 'returns array of results' do
        expect(subject.extract_value('input')).to eq(n1: 1, n2: 2)
      end
    end
  end

  describe '#call' do
  end
end
