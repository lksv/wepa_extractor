describe WepaExtractor::Matcher::BasicMatcher do
  class FakeSubClass < WepaExtractor::Matcher::BasicMatcher
  end

  let(:subject) { WepaExtractor::Matcher::BasicMatcher.new('selector') }

  it 'takes one param which is readabe' do
    expect(subject.selector).to eq 'selector'
  end

  describe '#inspect' do
    it 'returns class name and selector' do
      expect(subject.inspect).to eq '#<BasicMatcher:"selector">'
      expect(FakeSubClass.new('sel').inspect).to eq '#<FakeSubClass:"sel">'
    end
  end

  describe '#as_json' do
    it 'returns selector and type' do
      expect(subject.as_json).to eq(selector: 'selector', type: 'BasicMatcher')
      expect(FakeSubClass.new('sel').as_json).to eq(selector: 'sel',
                                                    type: 'FakeSubClass')
    end
  end
end

describe WepaExtractor::Matcher::Const do
  let(:subject) { WepaExtractor::Matcher::Const.new('selector') }

  it '#call returns selector itselfs' do
    expect(subject.call(:anything)).to eq 'selector'
    expect(subject.call('anything_else')).to eq 'selector'
  end
end

describe WepaExtractor::Matcher::Css do
  let(:subject) { WepaExtractor::Matcher::Css.new('selector') }

  it 'delegates call to inputs #css method' do
    input = double('Node')
    expect(input).to receive(:css).with('selector').and_return(:result)
    expect(subject.call(input)).to eq :result
  end
end

describe WepaExtractor::Matcher::Xpath do
  let(:subject) { WepaExtractor::Matcher::Xpath.new('selector') }

  it 'delegates call to inputs #xpath method' do
    input = double('Node')
    expect(input).to receive(:xpath).with('selector').and_return(:result)
    expect(subject.call(input)).to eq :result
  end
end
