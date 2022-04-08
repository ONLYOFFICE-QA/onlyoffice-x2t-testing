# frozen_string_literal: true

describe XmlParams do
  source_filepath = './tmp/86476809/(NS)-CHAUZIMU-MWA-CHILENGEDWE.doc'
  converted_filepath = './tmp/331411115.docx'
  fonts_path = './assets/fonts'
  format = :docx
  xml = described_class.new(fonts_path: fonts_path, tmp_path: StaticData::TMP_DIR)
  xml_template = File.open('./spec/unit/template.xml') { |f| Nokogiri::XML(f) }
  created_xml = File.open(xml.create_xml(source_filepath, converted_filepath, format)) { |f| Nokogiri::XML(f) }
  it 'check source filepath' do
    expect(created_xml.at('m_sFileFrom').content).to eq(source_filepath)
  end

  it 'check converted filepath' do
    expect(created_xml.at('m_sFileTo').content).to eq(converted_filepath)
  end

  it 'check conversion format' do
    expect(created_xml.at('m_nFormatTo').content).to eq('65')
  end

  it 'check fonts path' do
    expect(created_xml.at('m_sFontDir').content).to eq(fonts_path)
  end

  it 'comparison of xml files' do
    expect(created_xml.to_xml).to eq(xml_template.to_xml)
  end
end
