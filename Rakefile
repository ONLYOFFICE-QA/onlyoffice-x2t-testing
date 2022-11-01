# frozen_string_literal: true

require_relative 'data/static_data'
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

desc 'Download core'
task :download_core do |_t|
  host_platform = 'linux'
  # branch = 'develop'
  # version = '99.99.99'
  # build = '-3141'
  branch = 'hotfix'
  version = 'v7.2.1'
  build = '/latest'
  arch = 'x64'

  url = "https://repo-doc-onlyoffice-com.s3.amazonaws.com/#{host_platform}/core/#{branch}/#{version}#{build}/#{arch}/core.7z"

  result = system("curl #{url} --output #{StaticData::TMP_DIR}/#{File.basename(url)}")

  if result
    File.open("#{StaticData::TMP_DIR}/#{File.basename(url)}", 'rb') do |file|
      SevenZipRuby::Reader.open(file) do |szr|
        szr.extract_all Dir.pwd.to_s
      end
    end

    # Make the x2t utility executable
    FileUtils.chmod('+x', Dir.glob("#{Dir.pwd}/#{File.basename(url, '.7z')}/*"))
  end
end
