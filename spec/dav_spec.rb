# frozen_string_literal: true

RSpec.describe YandexClient::Dav do
  describe '.with_token' do
    context 'when call "with_token"' do
      it { expect(described_class.with_token('zozo')).to have_attributes(token: 'zozo') }
    end

    context 'when []' do
      it { expect(described_class['zozo']).to have_attributes(token: 'zozo') }
    end
  end

  describe '#put' do
    context 'when successful upload with string argument' do
      subject(:upload) do
        VCR.use_cassette('dav/put_success') do
          files = described_class[API_ACCESS_TOKEN].
            put('Gemfile', 'Gemfile').
            propfind.map(&:name)

          described_class[API_ACCESS_TOKEN].delete('Gemfile')

          files
        end
      end

      it { is_expected.to include('/Gemfile') }
    end

    context 'when path does not exist' do
      subject(:upload) do
        VCR.use_cassette('dav/put_not_found') { described_class[API_ACCESS_TOKEN].put('Gemfile', '/path/Gemfile') }
      end

      it do
        expect { upload }.to raise_error(YandexClient::ApiRequestError, /409 Conflict/)
      end
    end

    context 'when local file does not exist' do
      subject(:upload) { described_class[API_ACCESS_TOKEN].put('Gemfile.1', '/path/Gemfile') }

      it do
        expect { upload }.to raise_error(Errno::ENOENT)
      end
    end

    context 'when successful upload with stream argument' do
      subject(:upload) do
        VCR.use_cassette('dav/put_success_io') do
          files = described_class[API_ACCESS_TOKEN].
            put(File.open('Gemfile', 'rb'), 'Gemfile').
            propfind.map(&:name)

          described_class[API_ACCESS_TOKEN].delete('Gemfile')

          files
        end
      end

      it { is_expected.to include('/Gemfile') }
    end

    context 'when successful upload with a tempfile argument' do
      subject(:upload) do
        VCR.use_cassette('dav/put_success_tmp') do
          files = described_class[API_ACCESS_TOKEN].
            put(tmp, 'Gemfile').
            propfind.map(&:name)

          described_class[API_ACCESS_TOKEN].delete('Gemfile')

          files
        end
      end

      let(:tmp) do
        Tempfile.new.tap do |tmp|
          tmp.write('test')
          tmp.rewind
        end
      end

      after do
        tmp.close
        tmp.unlink
      end

      it { is_expected.to include('/Gemfile') }
    end

    context 'when yandex api is unreachable' do
      subject(:upload) { described_class[API_ACCESS_TOKEN].put('Gemfile', 'Gemfile') }

      before { stub_request(:put, /webdav.yandex.ru/).to_timeout }

      it do
        expect { upload }.to raise_error(HTTP::TimeoutError)
      end
    end

    context 'when call with file attributes' do
      before do
        stub_request(:put, /webdav.yandex.ru/).to_return(
          status: 200,
          body: 'Hardlinked'
        )

        allow(File).to receive(:size)
        allow(Digest::SHA256).to receive(:file)
        allow(Digest::MD5).to receive(:file)

        described_class[API_ACCESS_TOKEN].put(
          'Gemfile',
          'Gemfile',
          etag: 'tag',
          sha256: 256,
          size: 1024
        )
      end

      it do
        expect(File).not_to have_received(:size)
        expect(Digest::SHA256).not_to have_received(:file)
        expect(Digest::MD5).not_to have_received(:file)
      end
    end
  end

  describe '#delete' do
    context 'when successful delete' do
      subject(:delete) do
        VCR.use_cassette('dav/delete_success') do
          described_class[API_ACCESS_TOKEN].
            put('Gemfile', 'Gemfile').
            delete('Gemfile').
            propfind.
            map(&:name)
        end
      end

      it { is_expected.not_to include('/Gemfile') }
    end

    context 'when delete path starting with /' do
      subject(:delete) do
        VCR.use_cassette('dav/delete_success') do
          described_class[API_ACCESS_TOKEN].
            put('Gemfile', 'Gemfile').
            delete('/Gemfile').
            propfind.
            map(&:name)
        end
      end

      it { is_expected.not_to include('/Gemfile') }
    end

    context 'when delete in folder' do
      subject(:delete) do
        VCR.use_cassette('dav/delete_success_in_folder') do
          files = described_class[API_ACCESS_TOKEN].
            mkcol('test').
            put('Gemfile', 'test/Gemfile').
            delete('test/Gemfile').
            propfind('test').
            map(&:name)

          described_class[API_ACCESS_TOKEN].delete('test')

          files
        end
      end

      it { is_expected.to eq(%w[/test/]) }
    end

    context 'when delete folder' do
      subject(:delete) do
        VCR.use_cassette('dav/delete_success_folder') do
          described_class[API_ACCESS_TOKEN].
            mkcol('test').
            delete('test').
            propfind.
            map(&:name)
        end
      end

      it { is_expected.not_to include('/test/') }
    end

    context 'when file does not exist' do
      subject(:delete) do
        VCR.use_cassette('dav/delete_wrong') { described_class[API_ACCESS_TOKEN].delete('test') }
      end

      it do
        expect { delete }.to raise_error(YandexClient::NotFoundError, /404 Not Found/)
      end
    end
  end

  describe '#mkcol' do
    context 'when new folder' do
      subject(:created_folders) do
        VCR.use_cassette('dav/mkcol_new_folder') do
          files = described_class[API_ACCESS_TOKEN].
            mkcol('02').
            propfind('02', 0).
            to_a

          described_class[API_ACCESS_TOKEN].delete('02')

          files
        end
      end

      it do
        expect(created_folders.size).to eq(1)

        expect(created_folders.first).to be_folder
        expect(created_folders.first).to have_attributes(name: '/02/')
      end
    end

    context 'when folder already exists' do
      subject(:upload) do
        VCR.use_cassette('dav/mkcol_folder_exists') do
          described_class[API_ACCESS_TOKEN].
            mkcol('03').
            mkcol('03')
        end
      end

      after do
        VCR.use_cassette('dav/mkcol_folder_exists_clear') { described_class[API_ACCESS_TOKEN].delete('03') }
      end

      it do
        expect { upload }.to raise_error(YandexClient::ApiRequestError, /405 Method Not Allowed/)
      end
    end

    context 'when parent folder does not exist' do
      subject(:upload) do
        VCR.use_cassette('dav/mkcol_wrong_path') do
          described_class[API_ACCESS_TOKEN].mkcol('02/03/04')
        end
      end

      it do
        expect { upload }.to raise_error(YandexClient::ApiRequestError, /409 Conflict/)
      end
    end
  end

  describe '#propfind' do
    context 'when depth is 0' do
      subject(:result) do
        VCR.use_cassette('dav/propfind_zero') do
          result = described_class[API_ACCESS_TOKEN].
            mkcol('test').
            propfind('test', 0).
            to_a

          described_class[API_ACCESS_TOKEN].delete('test')

          result
        end
      end

      it do
        expect(result.size).to eq(1)
        expect(result.first).to have_attributes(name: '/test/')
      end
    end

    context 'when depth is 1' do
      subject(:result) do
        VCR.use_cassette('dav/propfind1') do
          result = described_class[API_ACCESS_TOKEN].
            mkcol('test').
            put('Gemfile', 'test/Gemfile').
            propfind('test').
            to_a

          described_class[API_ACCESS_TOKEN].delete('test')

          result
        end
      end

      it do
        expect(result.size).to eq(2)
        expect(result.map(&:name)).to match_array(%w[/test/ /test/Gemfile])
      end
    end

    context 'when wrong depth' do
      subject(:result) do
        VCR.use_cassette('dav/propfind_wrong') do
          described_class[API_ACCESS_TOKEN].propfind('', 2)
        end
      end

      it do
        expect { result }.to raise_error(YandexClient::ApiRequestError, /http code 403/)
      end
    end

    context 'when object does not exist' do
      subject(:result) do
        VCR.use_cassette('dav/propfind_not_exists') { described_class[API_ACCESS_TOKEN].propfind('test') }
      end

      it do
        expect { result }.to raise_error(YandexClient::NotFoundError, /404 Not Found/)
      end
    end
  end
end
