# frozen_string_literal: true

require 'benchmark'
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
  # branch = 'develop'
  # version = 'v99.99.99'
  # build = '99.99.99-3141'
  @branch = 'hotfix'
  @version = 'v7.2.1'
  @build = 'latest'
  # @build = '7.2.1-49' # The difference in builds for different os
  @arch = Gem::Platform.local.cpu

  case Gem::Platform.local.os
  when 'mingw'
    @os = 'windows'
  when 'linux'
    @os = 'linux'
  else
    p 'Error: definition os'
  end

  url = "https://repo-doc-onlyoffice-com.s3.eu-west-1.amazonaws.com/#{@os}/core/#{@branch}/#{@version}/#{@build}/#{@arch}/core.7z"

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

desc 'Estimate documents run'
task :estimate_documents_run do |_t|
  Benchmark.bm do |x|
    x.report(:documents) do
      `rspec spec/functional/documents/oform/* \\
             spec/functional/documents/docxf/* \\
             spec/functional/documents/docx/* \\
             spec/functional/documents/doc/*`
    end
  end
end

desc 'Parallel test with current num cores for documents'
task :parallel_estimate_documents_run, :cores do |_t, args|
  before = Time.now
  system("parallel_rspec -n #{args[:cores]} spec/functional/documents/oform/* spec/functional/documents/docxf/* spec/functional/documents/docx/* spec/functional/documents/doc/*")
  p "Estimate: #{Time.now - before}"
end

desc 'Estimate presentation run'
task :estimate_presentation_run do |_t|
  Benchmark.bm do |x|
    x.report(:presentation) do
      `rspec spec/functional/presentation/ppt/* \\
             spec/functional/presentation/pptx/*`
    end
  end
end

desc 'Parallel test with current num cores for presentation'
task :parallel_estimate_presentation_run, :cores do |_t, args|
  Benchmark.bm do |x|
    x.report(:presentation) do
      `parallel_rspec -n #{args[:cores]} spec/functional/presentation/ppt/* \\
                                         spec/functional/presentation/pptx/*`
    end
  end
end

desc 'Estimate spreadsheets run'
task :estimate_spreadsheets_run do |_t|
  Benchmark.bm do |x|
    x.report(:spreadsheets) do
      `rspec spec/functional/spreadsheets/xls/* \\
             spec/functional/spreadsheets/xlsx/*`
    end
  end
end

desc 'Parallel test with current num cores for spreadsheets'
task :parallel_estimate_spreadsheets_run, :cores do |_t, args|
  Benchmark.bm do |x|
    x.report(:spreadsheets) do
      `parallel_rspec -n #{args[:cores]} spec/functional/spreadsheets/xls/* \\
                                         spec/functional/spreadsheets/xlsx/*`
    end
  end
end
