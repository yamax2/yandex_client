require 'spec_helper'

RSpec.describe YandexPhotoStorage::Dav::PropfindParser do
  subject { described_class.call(xml) }

  context 'when depth is 0' do
    let(:xml) { File.read('spec/fixtures/propfind_depth0.xml') }

    it do
      expect(subject.keys).to match_array(%w[/01/dip.yml])
    end
  end

  context 'when depth is 1' do
    let(:xml) { File.read('spec/fixtures/propfind_depth1.xml') }

    it do
      expect(subject.keys).to match_array(%w[
        /
        /01/
        /Max/
        /photos/
        /Загрузки/
        /06091705_0008.MP4
        /33.mp4
        /34.mp4
        /35.mp4
        /P_20180101_171450_LL_1.jpg
        /V_20161029_202223.mp4
      ])

      %w[/ /01/ /Max/ /photos/ /Загрузки/].each do |folder|
        expect(subject[folder][:resourcetype]).to eq(:folder)
      end

      %w[/06091705_0008.MP4 /33.mp4 /34.mp4 /35.mp4 /P_20180101_171450_LL_1.jpg /V_20161029_202223.mp4].each do |file|
        expect(subject[file][:resourcetype]).to eq(:file)
        expect(subject[file][:getcontentlength]).to be_a(Integer)
      end
    end
  end

  context 'when wrong input text' do
    let(:xml) { 'qq' }

    it { expect { subject }.to raise_error(Ox::ParseError) }
  end
end
