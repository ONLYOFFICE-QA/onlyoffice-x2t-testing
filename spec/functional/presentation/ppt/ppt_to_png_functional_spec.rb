# frozen_string_literal: true

require 'rspec'
result_handler = ResultHandler.new(x2t.version, 'Ppt to Png')
# result_sets = palladium.get_result_sets(StaticData::POSITIVE_STATUSES)
# files = s3.files_from_folder('ppt')

format = 'ppt'
files = Dir["#{StaticData::TMP_DIR}/../documents/*.#{format}"]

describe 'Conversion ppt files to png' do
  before do
    @tmp_dir = create_tmp_dir.first
  end

  # (files - result_sets.map { |result_set| "ppt/#{result_set}" }).each do |file|
  files.each do |file|
    it File.basename(file) do
      # s3.download_file_by_name(file, @tmp_dir)
      FileUtils.cp(file, "#{@tmp_dir}/#{File.basename(file)}")
      @file_data = x2t.convert("#{@tmp_dir}/#{File.basename(file)}", :png)
      expect(File).to exist(@file_data[:tmp_filename])
    end
  end

  after do |example|
    spec_cleanup(@tmp_dir, @file_data[:tmp_filename])
    result_handler.add_result(example)
  end
end
