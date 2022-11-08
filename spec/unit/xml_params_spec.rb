# frozen_string_literal: true

require 'rspec'
require 'pathname'

describe XmlParams do
  source_filepath = './tmp/file.doc'
  converted_filepath = './tmp/file.docx'
  fonts_path = './assets/fonts'
  format = :docx
  csv_txt_encoding = 'UTF-8'

  xml = described_class.new(fonts_path:, tmp_path: StaticData::TMP_DIR)
  created_xml = xml.create_tmp(source_filepath, converted_filepath, format, csv_txt_encoding)
  parsed_result = File.open(created_xml) { |f| Nokogiri::XML(f) }
  it 'check source filepath' do
    expect(parsed_result.at('m_sFilerom').content).to eq(source_filepath)
  end

  it 'check converted filepath' do
    expect(parsed_result.at('m_sFileTo').content).to eq(converted_filepath)
  end

  it 'check conversion format' do
    expect(parsed_result.at('m_nFormatTo').content).to eq(XmlParams::FORMAT_NUMBERS[format])
  end

  it 'check fonts path' do
    expect(parsed_result.at('m_sFontDir').content).to eq(fonts_path)
  end

  it 'check CsvTxtEncoding' do
    expect(parsed_result.at('m_nCsvTxtEncoding').content).to eq(xml.encode_number_by_name(csv_txt_encoding))
  end

  it 'comparison of xml files' do
    expect(File.read(created_xml)).to eq(File.read('./spec/unit/simple_sample.xml'))
  end

  it 'check method: encode_number_by_name' do
    expect { xml.encode_number_by_name('Unknown') }.to raise_error(RuntimeError, 'Unknown encoding: Unknown')
  end

  describe XmlParams, type: :aruba do
    described_class.create_doc_renderer_config(StaticData::TMP_DIR.to_s)
    path_to = "#{StaticData::TMP_DIR}/DoctRenderer.config"
    array = File.read(path_to).split
    after(:all) do
      FileUtils.rm(path_to)
    end

    it 'Check exist DoctRenderer.config' do
      expect(Pathname.new(path_to)).to exist
      expect(Pathname.new(path_to)).to be_file
    end

    it 'Check the file line by line' do
      expect(array).to include(match(/native.js/))
      expect(array).to include(match(/jquery_native.js/))
      expect(array).to include(match(/AllFonts.js/))
      expect(array).to include(match(/xregexp-all-min.js/))
      expect(array).to include(match(/sdkjs/))
    end
  end
end
