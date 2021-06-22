# frozen_string_literal: true

RSpec.describe YandexClient::Passport do
  let(:logger) { instance_double(Logger) }

  before do
    allow(YandexClient.config).to receive(:logger).and_return(logger)

    allow(logger).to receive(:info)
    allow(logger).to receive(:debug)
  end

  describe '#info' do
    context 'when valid token' do
      subject(:info) do
        VCR.use_cassette('passport/info_success') do
          described_class[API_ACCESS_TOKEN].info
        end
      end

      it do
        expect(info).to include(:client_id, :login, :id)

        expect(logger).to have_received(:info).at_least(1)
        expect(logger).to have_received(:debug).at_least(1)
      end
    end

    context 'when invalid token' do
      subject(:info) do
        VCR.use_cassette('passport/info_failed') do
          described_class['zozo'].info
        end
      end

      it do
        expect { info }.to raise_error(YandexClient::ApiRequestError, /401 Unauthorized/)
      end
    end
  end

  context 'when api is unreachable' do
    before { stub_request(:any, /login.yandex.ru/).to_timeout }

    it do
      expect { described_class[API_ACCESS_TOKEN].info }.to raise_error(HTTP::TimeoutError)
    end
  end
end
