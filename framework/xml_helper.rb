# frozen_string_literal: true

# methods for working with xml
class XmlParams
  # To convert via xml use a decimal number.
  # A list of all the codes in HEX formats is described in
  # https://github.com/ONLYOFFICE/core/blob/master/Common/OfficeFileFormats.h
  FORMAT_NUMBERS = {
    docx: '65',
    odt: '67',
    rtf: '68',
    xlsx: '257',
    ods: '259',
    pptx: '129',
    odp: '131'
  }.freeze

  # :fonts_path  - is a path to folder with fonts
  # :tmp_path  - is a path to temp folder
  def initialize(options = {})
    @fonts_path = options[:fonts_path]
    @tmp_path = options[:tmp_path]
  end

  # @param [String] source_filepath is a path to file for convert
  # @param [String] converted_filepath file path after conversion
  # @param [Symbol] format is a format for conversion
  # @param [String] csv_txt_encoding is a csv txt encoding number
  # @return [String] path to result xml
  def create_xml(source_filepath, converted_filepath, format, csv_txt_encoding)
    xml_parameters = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.TaskQueueDataConvert('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                               'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema') do
        xml.m_sFileFrom(source_filepath)
        xml.m_sFileTo(converted_filepath)
        xml.m_nFormatTo(FORMAT_NUMBERS[format])
        xml.m_nCsvTxtEncoding(csv_txt_encoding)
        xml.m_sFontDir(@fonts_path)
      end
    end
    write_xml_to_file(xml_parameters)
  end

  # Creates a unique temporary xml-file
  # @return [String] path to result xml
  def write_xml_to_file(xml_parameters)
    file = Tempfile.new(%w[params .xml], @tmp_path)
    file.write(xml_parameters.to_xml)
    file.read       # Without this line - file cannot be read by x2t for some unknown reason
    file.path.to_s
  end
end
