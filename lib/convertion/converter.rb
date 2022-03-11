# frozen_string_literal: true

require_relative '../app_manager'
require 'ooxml_parser'
require 'yaml'
# use Converter.new.convert for convert by config
class Converter
  def initialize
    config = YAML.load_file('configure.json')
    @convert_from = config['convert_from']
    @custom_folder = config['custom_folder']
    @convert_to = config['convert_to']
    @bin_path = config['x2t_path']
    @font_path = config['font_path']
    @conversion_formats = config['conversion_formats']
    @output_format = config['custom_format']
    @input_format = Time.now.strftime('%d-%b-%Y_%H-%M-%S').to_s
    @version_ds = ds_version
  end

  # @param [String] path is a path to folder
  def get_file_paths_list(path)
    FileHelper.list_file_in_directory(path)
  end

  # @param [String] folder_name - name for new folder
  def create_folder(folder_name)
    FileHelper.create_folder(folder_name)
    FileHelper.create_folder("#{folder_name}/not_converted")
  end

  # @param [String] input_filename - input filename with format
  def convert_file(input_filename, performance_test, ooxmlparser)
    count = 1
    count = 5 if performance_test
    output_filepath = get_output_filepath(input_filename)
    time = []
    count.times do
      File.delete(output_filepath) if File.exist?(output_filepath)
      LoggerHelper.print_to_log "Start convert file #{input_filename} to #{output_filepath}"
      command = "\"#{@bin_path}\" \"#{input_filename}\" \"#{output_filepath}\" \"#{@font_path}\""
      LoggerHelper.print_to_log "Run command #{command}"
      time_before = Time.now
      `#{command}`
      time << (Time.now - time_before)
    end
    time << average_convert_time(time) if performance_test
    check_file_exist(input_filename, output_filepath, time.join(';'))
    LoggerHelper.print_to_log 'End convert'
    check_ooxmlparser(output_filepath) if ooxmlparser
    puts '--' * 75
  end

  def check_ooxmlparser(filepath)
    OoxmlParser::Parser.parse(filepath)
  rescue StandardError => e
    LoggerHelper.print_to_log "Error: #{e}"
    errorfolder = "#{@output_folder}/error"
    FileHelper.move_file(filepath, errorfolder)
    File.open("#{errorfolder}/errors.csv", 'a') do |file|
      file.write "#{file_name(filepath)};#{e};\n"
    end
  end

  def check_file_exist(input_filename, output_filepath, time)
    if File.exist?(output_filepath)
      File.open("#{@output_folder}/results.csv", 'a') do |file|
        file.write "#{file_name(input_filename)};#{file_size(input_filename)};#{time};true;\n"
      end
    else
      File.open("#{@output_folder}/results.csv", 'a') do |file|
        file.write "#{file_name(input_filename)};#{file_size(input_filename)};#{time};false;\n"
      end
      FileHelper.copy_file(input_filename, "#{@output_folder}/not_converted")
    end
  end

  def file_name(input_filename)
    File.basename(input_filename)
  end

  def file_size(input_filename)
    FileHelper.file_size(input_filename) / 1000 / 1000.0
  end

  def x2t_exist?
    File.exist?(@bin_path)
  end

  def get_output_filepath(filepath)
    @output_folder + '/' + File.basename(filepath, '.*') + '.' + @output_format
  end

  def check_macros(file)
    system "\"#{@bin_path}\" -detectmacro \"#{file}\""
    $CHILD_STATUS.exitstatus != 0
  end

  # getting a version of the document server
  def ds_version
    version = File.read('.env').strip
    version.split('=')[-1]
  end

  def convert(performance_test = false, ooxmlparser = false, file_path = @custom_folder)
    @output_folder = "#{@convert_to}/#{@version_ds}_#{@input_format}_#{@output_format}"
    create_folder @output_folder
    first_line_result(performance_test)
    files = get_file_paths_list(file_path)
    files.each do |current_file_to_convert|
      p current_file_to_convert
      if @output_format == ('docm' || 'xlsm' || 'pptm')
        if check_macros(current_file_to_convert)
          p "Skip #{current_file_to_convert} because it has no macros for #{@output_format}"
          next
        end
      end
      convert_file(current_file_to_convert, performance_test, ooxmlparser)
    end
  end

  def convert_from_array_extensions(parser)
    @conversion_formats.map do |format|
      @input_format = format[0]
      @output_format = format[1]
      file_path = "#{@convert_from}/#{@input_format}/"
      convert(false, parser, file_path)
    end
  end

  def convert_with_options(convert_flag, parser)
    case convert_flag
    when :arr
      convert_from_array_extensions(parser)
    when :cstm
      convert(false, parser)
    else
      message = 'Input Error' \
                'Please,enter the correct parameters' \
                'Example: rake convert[arr]'
      puts(message)
    end
  end

  def first_line_result(performance_test)
    if performance_test
      File.write("#{@output_folder}/results.csv", "filename;filesize(kbytes);time 1;time 2;time 3;time 4;time 5;average;convert_status\n")
    else
      File.write("#{@output_folder}/results.csv", "filename;filesize(kbytes);time(sec);convert_status\n")
    end
  end

  private

  # Calculate average convert time from array
  # @param times [Array<Float>] array of convert time
  # @return [Float] average time of convert
  def average_convert_time(times)
    times.inject(:+).to_f / times.size
  end
end
