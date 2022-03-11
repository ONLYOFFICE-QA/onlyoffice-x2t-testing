# frozen_string_literal: true

require_relative 'lib/app_manager'

desc 'convert files from custom configure.json'
task :convert, :convert_flag, :parser do |_t, args|
  parser = args[:parser]
  convert_flag = args[:convert_flag].to_sym
  Converter.new.convert_with_options(convert_flag, parser)
end

desc 'Create a detailed report with performance tests'
task :convert_only_report do |_t|
  Converter.new.convert(true)
end
