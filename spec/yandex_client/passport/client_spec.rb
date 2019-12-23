# frozen_string_literal: true

require 'spec_helper'

RSpec.describe YandexClient::Passport::Client do
  let(:access_token) { 'access_token' }
  let(:service) { described_class.new(access_token: access_token) }
  let(:logger) { instance_double(Logger) }

  before do
    allow(YandexClient.config).to receive(:logger).and_return(logger)
    allow(logger).to receive(:info)
  end

  describe '#info' do
    context 'when valid token' do
      let(:access_token) { API_ACCESS_TOKEN }

      subject { VCR.use_cassette('passport_info') { service.info } }

      it do
        is_expected.to include(
          :client_id,
          :login,
          :id
        )

        expect(logger).to have_received(:info).exactly(3).times
      end
    end

    context 'when invalid token' do
      let(:access_token) { 'wrong_token' }

      subject { VCR.use_cassette('passport_info_error') { service.info } }

      it do
        expect { subject }.
          to raise_error(YandexClient::ApiRequestError, 'http code 401')

        expect(logger).to have_received(:info).exactly(3).times
      end
    end

    context 'when api is unreachable' do
      before { stub_request(:any, /login.yandex.ru/).to_timeout }

      it do
        expect { service.info }.to raise_error(Net::OpenTimeout)
      end
    end
  end

  describe 'wrong action' do
    it do
      expect { service.wrong_action }.to raise_error(NoMethodError)
    end
  end
end
