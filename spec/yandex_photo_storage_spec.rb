RSpec.describe YandexPhotoStorage do
  it 'has a version number' do
    expect(YandexPhotoStorage::VERSION).not_to be nil
  end

  it 'works with pg' do
    expect { ActiveRecord::Base.connection.execute('select version()') }.not_to raise_error
  end

  describe '.configure' do
    it 'yields a config object' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class::Config)
    end
  end

  describe '.config' do
    it do
      expect(described_class.config).to be_a(described_class::Config)

      %i[api_key api_secret logger token_model_klass].each do |key|
        expect(described_class.config).to respond_to(key)
      end
    end
  end
end
