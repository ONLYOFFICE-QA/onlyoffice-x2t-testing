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
    ENV['LD_LIBRARY_PATH'] = options[:lib_path]
  end

  # getting x2t version
  def version
    `#{@path}`.match(/Version: (.*)/)[1]
  end

  def run(command)
    `#{@path} ` + command
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
               param_xml_path = xml.create_xml(filepath, tmp_filename, format)
               `#{@path} "#{param_xml_path}" 2>&1`
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
