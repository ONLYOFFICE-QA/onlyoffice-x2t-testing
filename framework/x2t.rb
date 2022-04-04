# frozen_string_literal: true

# class for adding ability to use x2t
class X2t
  # @param [Hash] options is a hash with required keys:
  # :x2t_path - is a path to x2t file
  # :fonts_path  - is a path to folder with fonts
  # :lib_path - is a path to all libs for x2t
  def initialize(options = {})
    @path = options[:x2t_path]
    @fonts_path = options[:fonts_path]
    @tmp_path = options[:tmp_path]
    @param_xml_path = options[:param_xml_path]
    ENV['LD_LIBRARY_PATH'] = options[:lib_path]
  end

  # getting x2t version
  def version
    `#{@path}`.match(/Version: (.*)/)[1]
  end

  def run(command)
    `#{@path} ` + command
  end

  # @param [String] source_filepath is a path to file for convert
  # @param [String] converted_filepath file path after conversion
  # @param [String] format is a format for conversion
  def amend_parameters_xml(source_filepath, converted_filepath, format)
    parameters = Nokogiri.XML(File.read(@param_xml_path))
    path_to_source_file = parameters.at('m_sFileFrom')
    path_to_source_file.content = source_filepath
    path_to_converted_file = parameters.at('m_sFileTo')
    path_to_converted_file.content = converted_filepath
    output_format = parameters.at('m_nFormatTo')
    output_format.content = StaticData::FORMAT_NUMBERS[format]
    fonts_dir = parameters.at('m_sFontDir')
    fonts_dir.content = @fonts_path
    File.open(@param_xml_path, 'w') { |f| f << parameters }
  end

  # @param [String] filepath is a path to file for convert
  # @param [String] format is a format for conversion
  # @param [Boolean] with_param_xml enables the conversion with parameters from the xml-file
  def convert(filepath, format, with_param_xml: true)
    tmp_filename = "#{@tmp_path}/#{Time.now.nsec}.#{format}"
    size_before = File.size(filepath)
    t_start = Time.now
    OnlyofficeLoggerHelper.log "#{@path} \"#{filepath}\" \"#{tmp_filename}\""
    output = if with_param_xml
               amend_parameters_xml(filepath, tmp_filename, format)
               `#{@path} "#{@param_xml_path}" 2>&1`
             else
               `#{@path} "#{filepath}" "#{tmp_filename}" "#{@fonts_path}" 2>&1`
             end
    elapsed = Time.now - t_start
    result = { tmp_filename: tmp_filename, elapsed: elapsed, size_before: size_before }
    result[:size_after] = File.size(tmp_filename) if File.exist?(tmp_filename)
    result[:x2t_result] = output.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').split("\n")[0..2].join("\n") if output != ''
    result
  end
end
