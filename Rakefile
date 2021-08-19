# frozen_string_literal: true

require_relative 'lib/app_manager'
desc 'convert files from custom configure.json'
# rake convert
task :convert do |_t|
  Converter.new.convert
end

desc 'Create a detailed report with performance tests'
task :convert_only_report do |_t|
  Converter.new.convert(true)
end
