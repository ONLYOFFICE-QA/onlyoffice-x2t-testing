# frozen_string_literal: true

require_relative 'data/static_data'
require_relative 'lib/app_manager'
require_relative 'management'

desc 'Convert files from custom configure.json'
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
task :core do |_t|
  # branch = 'develop'
  # version = 'v99.99.99'
  # build = '99.99.99-3141'
  @branch = 'hotfix'
  @version = 'v7.2.1'
  @build = 'latest'
  # @build = '7.2.1-53' # The difference in builds for different os
  @arch = Gem::Platform.local.cpu

  case Gem::Platform.local.os
  when 'mingw'
    @os = 'windows'
  when 'linux'
    @os = 'linux'
    @arch = @arch.sub('86_', '')
  when 'darwin'
    @os = 'mac'
    @arch = @arch.sub('arm', 'x')
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
    FileUtils.chmod('+x', Dir.glob("#{Dir.pwd}/#{File.basename(url, '.7z')}/*")) if @os.include?('linux')
  end

  XmlParams.create_doc_renderer_config(StaticData::PROJECT_BIN_PATH)

  # Generate AllFonts.js
  `#{StaticData::PROJECT_BIN_PATH}/standardtester`
  FileUtils.cp("#{StaticData::PROJECT_BIN_PATH}/fonts/AllFonts.js", StaticData::PROJECT_BIN_PATH.to_s)
end

desc 'Estimate run'
task :estimate_run, :cores, :specs do |_t, args|
  presentation_specs = 'spec/functional/presentation/ppt/* \\
                        spec/functional/presentation/pptx/*'
  documents_specs = 'spec/functional/documents/oform/* \\
                     spec/functional/documents/docxf/* \\
                     spec/functional/documents/docx/* \\
                     spec/functional/documents/doc/*'
  spreadsheets_spec = 'spec/functional/spreadsheets/xls/* \\
                       spec/functional/spreadsheets/xlsx/*'
  specs_for_test = case args[:specs].to_sym
                   when :presentation
                     presentation_specs
                   when :documents
                     documents_specs
                   when :spreadsheets
                     spreadsheets_spec
                   when :all
                     "#{presentation_specs} #{documents_specs} #{spreadsheets_spec}"
                   else
                     message = 'Input Error. Please, enter the correct parameters, ' \
                               'Example: rake estimate_run[core, specs]'
                     puts(message)
                   end
  time_before = Time.now
  system("parallel_rspec -n #{args[:cores]} #{specs_for_test}")
  p "Result time in seconds: #{Time.now - time_before}"
end
