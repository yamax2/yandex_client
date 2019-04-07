RSpec.describe YandexPhotoStorage do
  it 'has a version number' do
    expect(YandexPhotoStorage::VERSION).not_to be nil
  end

  it 'works with pg' do
    expect { ActiveRecord::Base.connection.execute('select version()') }.not_to raise_error
  end
end
