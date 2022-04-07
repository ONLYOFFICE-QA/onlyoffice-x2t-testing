# frozen_string_literal: true

# methods for working with xml
class XmlParams
  # :fonts_path  - is a path to folder with fonts
  # :tmp_path  - is a path to temp folder
  def initialize(options = {})
    @fonts_path = options[:fonts_path]
    @tmp_path = options[:tmp_path]
  end

  # @param [String] source_filepath is a path to file for convert
  # @param [String] converted_filepath file path after conversion
  # @param [String] format is a format for conversion
  def create_xml(source_filepath, converted_filepath, format)
    xml_parameters = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.TaskQueueDataConvert('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                               'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema') do
        xml.m_sFileFrom source_filepath
        xml.m_sFileTo   converted_filepath
        xml.m_nFormatTo StaticData::FORMAT_NUMBERS[format]
        xml.m_sFontDir  @fonts_path
      end
    end
    write_xml_to_file(xml_parameters)
  end

  # @return path to xml-file
  def write_xml_to_file(xml_parameters)
    param_xml_path = "#{@tmp_path}/#{Time.now.nsec}.xml"
    File.open(param_xml_path, 'w') { |f| f << xml_parameters.to_xml }
    param_xml_path
  end
end
