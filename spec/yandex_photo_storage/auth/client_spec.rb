require 'spec_helper'

RSpec.describe YandexPhotoStorage::Auth::Client do
  let(:logger) { instance_double(Logger) }
  let(:service) { described_class.new }

  before do
    allow(YandexPhotoStorage.config).to receive(:api_key).and_return(API_APPLICATION_KEY)
    allow(YandexPhotoStorage.config).to receive(:api_secret).and_return(API_APPLICATION_SECRET)
    allow(YandexPhotoStorage.config).to receive(:logger).and_return(logger)

    allow(logger).to receive(:info)
  end

  describe '#create_token' do
    # https://oauth.yandex.ru/authorize?response_type=code&client_id=99bcbd17ad7f411694710592d978a4a2&force_confirm=false
    context 'when correct code' do
      subject { VCR.use_cassette('auth_create_token_success') { service.create_token(code: '1445655') } }

      it do
        is_expected.to include(:token_type, :access_token, :expires_in, :refresh_token)

        expect(logger).to have_received(:info).exactly(5).times
      end
    end

    context 'when incorrect code' do
      subject { VCR.use_cassette('auth_create_token_wrong_code') { service.create_token(code: 100_500) } }

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'bad_verification_code, Invalid code, http code 400')

        expect(logger).to have_received(:info).exactly(5).times
      end
    end

    context 'when incorrect api app keys' do
      before do
        allow(YandexPhotoStorage.config). to receive(:api_key).and_return('wrong')
        allow(YandexPhotoStorage.config). to receive(:api_secret).and_return('wrong')
      end

      subject { VCR.use_cassette('auth_create_token_wrong_keys') { service.create_token(code: 100_500) } }

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'invalid_client, Client not found, http code 400')

        expect(logger).to have_received(:info).exactly(5).times
      end
    end

    context 'when without code in params' do
      subject { VCR.use_cassette('auth_create_without_code') { service.create_token } }

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'invalid_request, code not in POST, http code 400')

        expect(logger).to have_received(:info).exactly(5).times
      end
    end

    context 'and expired code' do
      subject { VCR.use_cassette('auth_create_expired_code') { service.create_token(code: '9857623') } }

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'invalid_grant, Code has expired, http code 400')

        expect(logger).to have_received(:info).exactly(5).times
      end
    end

    context 'when api is unreachable' do
      before { stub_request(:any, /oauth.yandex.ru/).to_timeout }

      it do
        expect { service.create_token }.to raise_error(Net::OpenTimeout)
      end
    end
  end

  describe '#refresh_token' do
    context 'when correct refresh_token' do
      subject do
        VCR.use_cassette('auth_refresh_token_success') { service.refresh_token(refresh_token: API_REFRESH_TOKEN) }
      end

      it do
        is_expected.to include(:access_token, :expires_in, :refresh_token, :token_type)

        expect(logger).to have_received(:info).exactly(5).times
      end
    end

    context 'when incorrect refresh_token' do
      subject { VCR.use_cassette('auth_refresh_token_wrong_token') { service.refresh_token(refresh_token: 'wrong') } }

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'invalid_grant, expired_token, http code 400')

        expect(logger).to have_received(:info).exactly(5).times
      end
    end

    context 'when incorrect api app keys' do
      before do
        allow(YandexPhotoStorage.config). to receive(:api_key).and_return('wrong')
        allow(YandexPhotoStorage.config). to receive(:api_secret).and_return('wrong')
      end

      subject do
        VCR.use_cassette('auth_refresh_token_wrong_keys') { service.refresh_token(refresh_token: API_REFRESH_TOKEN) }
      end

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'invalid_client, Client not found, http code 400')

        expect(logger).to have_received(:info).exactly(5).times
      end
    end

    context 'when api is unreachable' do
      before { stub_request(:any, /oauth.yandex.ru/).to_timeout }

      it do
        expect { service.refresh_token }.to raise_error(Net::OpenTimeout)
      end
    end
  end

  describe 'wrong method' do
    it do
      expect { service.wrong_action }.to raise_error(NoMethodError)
    end
  end
end
