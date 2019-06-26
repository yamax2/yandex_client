require 'spec_helper'

RSpec.describe YandexPhotoStorage::Dav::Client do
  let(:service) { described_class.new(access_token: API_ACCESS_TOKEN) }

  describe '#propfind' do
    context 'when depth is 0' do
      subject do
        VCR.use_cassette('dav_propfind_depth0') { service.propfind(name: '/01/dip.yml', depth: 0) }
      end

      it { is_expected.to include('/01/dip.yml') }
    end

    context 'when depth is 1' do
      subject do
        VCR.use_cassette('dav_propfind_depth1') { service.propfind(name: '/01', depth: 1) }
      end

      it { is_expected.to include('/01/', '/01/dip.yml') }
    end

    context 'when wrong depth' do
      subject do
        VCR.use_cassette('dav_propfind_depth_wrong') { service.propfind(name: '/01', depth: 2) }
      end

      it do
        expect { subject }.to raise_error(YandexPhotoStorage::ApiRequestError, 'http code 403')
      end
    end

    context 'when without depth param' do
      subject do
        VCR.use_cassette('dav_propfind_without_depth') { service.propfind(name: '/01/dip.yml') }
      end

      it { is_expected.to include('/01/dip.yml') }
    end

    context 'when without name param' do
      subject { service.propfind }

      it do
        expect { subject }.to raise_error(KeyError)
      end
    end

    context 'when quota query' do
      subject do
        VCR.use_cassette('dav_propfind_quota') { service.propfind(name: '/', quota: true) }
      end

      it do
        expect(subject['/']).to include(:'quota-used-bytes', :'quota-available-bytes')
      end
    end

    context 'when object does not exist' do
      subject do
        VCR.use_cassette('dav_propfind_404') { service.propfind(name: '/photo1') }
      end

      it do
        expect { subject }.to raise_error(YandexPhotoStorage::NotFoundError, 'resource not found, http code 404')
      end
    end
  end

  describe '#mkcol' do
    context 'when new folder' do
      subject do
        VCR.use_cassette('dav_mkcol_new_folder') { service.mkcol(name: '/02') }
      end

      it { is_expected.to be_nil }
    end

    context 'when folder already exists' do
      subject do
        VCR.use_cassette('dav_mkcol_folder_exists') do
          service.mkcol(name: '/03')
          service.mkcol(name: '/03')
        end
      end

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'mkdir: resource already exists, http code 405')
      end
    end

    context 'when parent folder does not exist' do
      subject do
        VCR.use_cassette('dav_mkcol_wrong_path') { service.mkcol(name: '/02/03/04') }
      end

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'mkdir: parent folder was not found, http code 409')
      end
    end
  end

  describe '#delete' do
    context 'when remove file' do
      subject do
        VCR.use_cassette('dav_delete_file') { service.delete(name: '/01/dip.yml') }
      end

      it { is_expected.to be_nil }
    end

    context 'when remove folder' do
      subject do
        VCR.use_cassette('dav_delete_folder') { service.delete(name: '/03') }
      end

      it { is_expected.to be_nil }
    end

    context 'when file does not exist' do
      subject do
        VCR.use_cassette('dav_delete_wrong_folder') { service.delete(name: '/03/dip.yml') }
      end

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::NotFoundError, 'resource not found, http code 404')
      end
    end
  end

  describe 'put' do
    context 'when first upload' do
      subject do
        VCR.use_cassette('dav_put_first_time') { service.put(name: '/01/test.txt', file: 'spec/fixtures/test.txt') }
      end

      it { is_expected.to be_nil }
    end

    context 'when second upload' do
      subject do
        VCR.use_cassette('dav_put_second_time') do
          service.put(name: '/01/test.txt', file: 'spec/fixtures/test.txt')
          service.put(name: '/01/test.txt', file: 'spec/fixtures/test.txt')
        end
      end

      it { is_expected.to eq('Hardlinked') }
    end

    context 'when path does not exist' do
      subject do
        VCR.use_cassette('dav_put_wrong_path') { service.put(name: '/03/test.txt', file: 'spec/fixtures/test.txt') }
      end

      it do
        expect { subject }.
          to raise_error(YandexPhotoStorage::ApiRequestError, 'store: parent folder was not found, http code 409')
      end
    end

    context 'when local file does not exist' do
      subject { service.put(name: 'zz.txt', file: 'spec/fixtures/zz.txt') }

      it do
        expect { subject }.to raise_error(Errno::ENOENT)
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

        service.put(
          name: '/01/test.txt',
          file: 'spec/fixtures/test.txt',
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

  describe 'wrong action' do
    it do
      expect { service.wrong_action }.to raise_error(NoMethodError)
    end
  end
end
