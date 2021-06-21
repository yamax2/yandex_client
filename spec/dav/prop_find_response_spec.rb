# frozen_string_literal: true

RSpec.describe YandexClient::Dav::PropFindResponse do
  subject(:response) { described_class.new(xml).to_a }

  context 'when depth is 0' do
    let(:xml) { File.read('spec/fixtures/propfind_depth0.xml') }

    it do
      expect(response.size).to eq(1)
      expect(response.first).not_to be_folder
      expect(response.first).to have_attributes(
        name: '/01/dip.yml',
        created_at: String,
        etag: String,
        last_modified: String,
        size: 1_113
      )
    end
  end

  context 'when depth is 1' do
    let(:xml) { File.read('spec/fixtures/propfind_depth1.xml') }

    it do
      expect(response.map(&:name)).to match_array(
        %w[
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
        ]
      )

      %w[/ /01/ /Max/ /photos/ /Загрузки/].each do |folder|
        expect(response.group_by(&:name).fetch(folder).first).to be_folder
      end
      %w[/06091705_0008.MP4 /33.mp4 /34.mp4 /35.mp4 /P_20180101_171450_LL_1.jpg /V_20161029_202223.mp4].each do |file|
        item = response.group_by(&:name).fetch(file).first

        expect(item).to be_file
        expect(item).to have_attributes(etag: String, size: Integer)
      end
    end
  end

  context 'when wrong input text' do
    let(:xml) { 'qq' }

    it { expect { response }.to raise_error(Ox::ParseError) }
  end
end
