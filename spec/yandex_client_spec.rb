RSpec.describe YandexClient do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'yields a config object' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class::Config)
    end
  end

  describe '.config' do
    it do
      expect(described_class.config).to be_a(described_class::Config)

      %i[api_key api_secret logger].each do |key|
        expect(described_class.config).to respond_to(key)
      end
    end
  end
end
