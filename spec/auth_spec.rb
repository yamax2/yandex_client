# frozen_string_literal: true

RSpec.describe YandexClient::Auth do
  let(:logger) { instance_double(Logger) }

  before do
    allow(YandexClient.config).to receive(:api_key).and_return(API_APPLICATION_KEY)
    allow(YandexClient.config).to receive(:api_secret).and_return(API_APPLICATION_SECRET)
    allow(YandexClient.config).to receive(:logger).and_return(logger)

    allow(logger).to receive(:info)
    allow(logger).to receive(:debug)
  end

  describe '#create_token' do
    # https://oauth.yandex.ru/authorize?response_type=code&client_id=ede5c51271164a9e833ab9119b4d3c26&force_confirm=false
    context 'when correct code' do
      subject(:info) do
        VCR.use_cassette('auth/create_token_success') { YandexClient.auth.create_token('7194497') }
      end

      it do
        expect(info).to include(:token_type, :access_token, :expires_in, :refresh_token)

        expect(logger).to have_received(:info).at_least(1)
        expect(logger).to have_received(:debug).at_least(1)
      end
    end

    context 'when incorrect token' do
      subject(:info) do
        VCR.use_cassette('auth/create_token_failed') { YandexClient.auth.create_token('4726731') }
      end

      it do
        expect { info }.to raise_error(YandexClient::ApiRequestError, /http code 400/)
      end
    end
  end

  describe '#refresh_token' do
    context 'when correct token' do
      subject(:info) do
        VCR.use_cassette('auth/refresh_token_success') { YandexClient.auth.refresh_token(API_REFRESH_TOKEN) }
      end

      it do
        expect(info).to include(:token_type, :access_token, :expires_in, :refresh_token)

        expect(logger).to have_received(:info).at_least(1)
        expect(logger).to have_received(:debug).at_least(1)
      end
    end

    context 'when incorrect token' do
      subject(:info) do
        VCR.use_cassette('auth/refresh_token_failed') { YandexClient.auth.refresh_token('zozo') }
      end

      it do
        expect { info }.to raise_error(YandexClient::ApiRequestError, /http code 400/)
      end
    end
  end

  context 'when api is unreachable' do
    before { stub_request(:any, /oauth.yandex.ru/).to_timeout }

    it do
      expect { YandexClient.auth.create_token('111') }.to raise_error(HTTP::TimeoutError)
    end
  end
end
