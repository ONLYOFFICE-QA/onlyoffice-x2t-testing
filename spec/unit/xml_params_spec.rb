# frozen_string_literal: true

describe XmlParams do
  source_filepath = './tmp/86476809/(NS)-CHAUZIMU-MWA-CHILENGEDWE.doc'
  converted_filepath = './tmp/331411115.docx'
  format = :docx
  it 'Comparison of xml files' do
    xml = described_class.new(fonts_path: './assets/fonts', tmp_path: StaticData::TMP_DIR)
    xml_template = File.open('./spec/unit/template.xml') { |f| Nokogiri::XML(f) }
    created_xml = File.open(xml.create_xml(source_filepath, converted_filepath, format)) { |f| Nokogiri::XML(f) }
    expect(created_xml.to_xml).to eq(xml_template.to_xml)
  end
end
