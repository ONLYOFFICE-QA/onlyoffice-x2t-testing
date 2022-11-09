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

  def xml
    @xml ||= XmlParams.new(fonts_path: @fonts_path,
                           tmp_path: @tmp_path)
  end

  def logger(message)
    OnlyofficeLoggerHelper.log(message)
  end

  # getting x2t version
  def version
    `#{@path}`.match(/Version: (.*)/)[1]
  end

  def run(command)
    `#{@path} ` + command
  end

  # @param [Symbol] format is a format for conversion
  # @return [String] Path to conversion file
  def generate_temp_filename(format)
    if %i[png jpg].include?(format)
      "#{@tmp_path}/#{Time.now.nsec}.zip"
    else
      "#{@tmp_path}/#{Time.now.nsec}.#{format}"
    end
  end

  # @param [String] filepath is a path to file for convert
  # @param [Symbol] format is a format for conversion
  # @param [String] csv_txt_encoding is a csv txt encoding
  # @return [Hash{Symbol->Unknown}]
  def convert(filepath, format, csv_txt_encoding: 'UTF-8')
    tmp_filename = generate_temp_filename(format)
    size_before = File.size(filepath)
    t_start = Time.now
    tmp_xml = xml.create_tmp(filepath, tmp_filename, format, csv_txt_encoding)
    output = `#{@path} #{tmp_xml.path} 2>&1`
    tmp_xml.close!
    elapsed = Time.now - t_start
    result = { tmp_filename:, elapsed:, size_before: }
    result[:size_after] = File.size(tmp_filename) if File.exist?(tmp_filename)
    result[:x2t_result] = output.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').split("\n")[0..2].join("\n") if output != ''
    logger "\"#{File.basename(filepath)}\" => \"#{File.basename(tmp_filename)}\" elapsed: #{elapsed}"
    logger result[:x2t_result] if output != ''
    result
  end
end
