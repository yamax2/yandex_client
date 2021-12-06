# frozen_string_literal: true

RSpec.describe YandexClient::Disk do
  let(:logger) { instance_double(Logger) }

  before do
    allow(YandexClient.config).to receive(:logger).and_return(logger)

    allow(logger).to receive(:info)
    allow(logger).to receive(:debug)
    allow(logger).to receive(:error)
  end

  describe '#info' do
    context 'when valid token' do
      subject(:info) { VCR.use_cassette('disk/info') { described_class[API_ACCESS_TOKEN].info } }

      it do
        expect(info).to include(:total_space, :used_space, :is_paid)

        expect(logger).to have_received(:info).at_least(1)
        expect(logger).to have_received(:debug).at_least(1)
      end
    end
  end

  describe '#download_url' do
    context 'when valid token' do
      subject(:url) do
        VCR.use_cassette('disk/rest_api_download') do
          YandexClient::Dav[API_ACCESS_TOKEN].put('Gemfile', 'Gemfile')

          url = described_class[API_ACCESS_TOKEN].download_url('Gemfile')

          YandexClient::Dav[API_ACCESS_TOKEN].delete('Gemfile')

          url
        end
      end

      it do
        expect(url).to match(%r{^https://downloader.disk.yandex.ru/disk/})

        expect(logger).to have_received(:info).at_least(1)
        expect(logger).to have_received(:debug).at_least(1)
      end
    end

    context 'when invalid path' do
      subject(:url) do
        VCR.use_cassette('disk/rest_api_download_wrong') do
          described_class[API_ACCESS_TOKEN].download_url('Gemfile')
        end
      end

      it do
        expect { url }.to raise_error(YandexClient::NotFoundError)
      end
    end
  end

  describe '#upload_url' do
    subject(:url) do
      VCR.use_cassette('disk/rest_api_upload') do
        described_class[API_ACCESS_TOKEN].upload_url('Gemfile', overwrite: true)
      end
    end

    it do
      expect(url).to match(%r{^https://.+disk.yandex})
    end
  end

  context 'when invalid token' do
    subject(:info) { VCR.use_cassette('disk/info_error') { described_class['wrong'].info } }

    it do
      expect { info }.to raise_error(YandexClient::ApiRequestError, /http code 401/)

      expect(logger).to have_received(:info).at_least(1)
      expect(logger).to have_received(:debug).at_least(1)
    end
  end

  context 'when api is unreachable' do
    before { stub_request(:any, /cloud-api.yandex.net/).to_timeout }

    it do
      expect { described_class[API_ACCESS_TOKEN].info }.to raise_error(HTTP::TimeoutError)
    end
  end
end
