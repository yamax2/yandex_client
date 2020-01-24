# frozen_string_literal: true

require 'spec_helper'

RSpec.describe YandexClient::Disk::Client do
  let(:logger) { instance_double(Logger) }
  let(:access_token) { API_ACCESS_TOKEN }
  let(:service) { described_class.new(access_token: access_token) }

  before do
    allow(YandexClient.config).to receive(:api_key).and_return(API_APPLICATION_KEY)
    allow(YandexClient.config).to receive(:api_secret).and_return(API_APPLICATION_SECRET)
    allow(YandexClient.config).to receive(:logger).and_return(logger)

    allow(logger).to receive(:info)
  end

  describe '#info' do
    context 'when valid token' do
      subject { VCR.use_cassette('disk_rest_api_info') { service.info } }

      it do
        is_expected.to include(:total_space, :used_space, :is_paid)
        expect(logger).to have_received(:info).exactly(3).times
      end
    end

    context 'when invalid token' do
      let(:access_token) { 'wrong_token' }

      subject { VCR.use_cassette('disk_rest_api_error') { service.info } }

      it do
        expect { subject }.
          to raise_error(YandexClient::ApiRequestError, 'UnauthorizedError, Unauthorized, http code 401')

        expect(logger).to have_received(:info).exactly(3).times
      end
    end

    context 'when api is unreachable' do
      before { stub_request(:any, /cloud-api.yandex.net/).to_timeout }

      it do
        expect { service.info }.to raise_error(Net::OpenTimeout)
      end
    end
  end

  describe '#download_url' do
    context 'when without path param' do
      it do
        expect { service.download_url(wrong: :param) }.to raise_error('required params not found: "path"')
      end
    end

    context 'when valid token' do
      subject { VCR.use_cassette('disk_rest_api_download') { service.download_url(path: '/test') } }

      it do
        is_expected.to include(:href)

        expect(logger).to have_received(:info).exactly(3).times
      end
    end

    context 'when invalid token' do
      let(:access_token) { 'wrong_token' }

      subject { VCR.use_cassette('disk_rest_api_download_error') { service.download_url(path: '/test') } }

      it do
        expect { subject }.
          to raise_error(YandexClient::ApiRequestError, 'UnauthorizedError, Unauthorized, http code 401')

        expect(logger).to have_received(:info).exactly(3).times
      end
    end

    context 'when wrong path' do
      subject { VCR.use_cassette('disk_rest_api_download_wrong_path') { service.download_url(path: 'Ыджыт Аттьӧ') } }

      it do
        expect { subject }.
          to raise_error(YandexClient::NotFoundError, 'DiskNotFoundError, Resource not found., http code 404')

        expect(logger).to have_received(:info).exactly(3).times
      end
    end

    context 'when api is unreachable' do
      before { stub_request(:any, /cloud-api.yandex.net/).to_timeout }

      it do
        expect { service.download_url(path: 'test') }.to raise_error(Net::OpenTimeout)
      end
    end
  end

  describe 'wrong action' do
    it do
      expect { service.wrong_action }.to raise_error(NoMethodError)
    end
  end
end
