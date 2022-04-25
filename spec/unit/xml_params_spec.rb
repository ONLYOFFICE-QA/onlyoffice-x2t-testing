# frozen_string_literal: true

describe XmlParams do
  source_filepath = './tmp/file.doc'
  converted_filepath = './tmp/file.docx'
  fonts_path = './assets/fonts'
  format = :docx
  csv_txt_encoding = :'UTF-8'
  xml = described_class.new(fonts_path: fonts_path, tmp_path: StaticData::TMP_DIR)
  created_xml = xml.create_xml(source_filepath, converted_filepath, format, csv_txt_encoding)
  parsed_result = File.open(created_xml) { |f| Nokogiri::XML(f) }
  it 'check source filepath' do
    expect(parsed_result.at('m_sFileFrom').content).to eq(source_filepath)
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
    expect(parsed_result.at('m_nCsvTxtEncoding').content).to eq(XmlParams::ENCODING_NUMBERS[csv_txt_encoding])
  end

  it 'comparison of xml files' do
    expect(File.read(created_xml)).to eq(File.read('./spec/unit/simple_sample.xml'))
  end
end
