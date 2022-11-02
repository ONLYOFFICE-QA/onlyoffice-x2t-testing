# frozen_string_literal: true

require 'rspec'
# palladium = PalladiumHelper.new(x2t.version, 'Ppt to Pptx')
# result_sets = palladium.get_result_sets(StaticData::POSITIVE_STATUSES)
# files = s3.files_from_folder('ppt')

format = 'ppt'
files = Dir["#{StaticData::TMP_DIR}/../documents/*.#{format}"]

describe 'Conversion ppt files to pptx' do
  before do
    @tmp_dir = create_tmp_dir.first
  end

  # (files - result_sets.map { |result_set| "ppt/#{result_set}" }).each do |file|
  files.each do |file|
    it File.basename(file) do
      # s3.download_file_by_name(file, @tmp_dir)
      FileUtils.cp(file, "#{@tmp_dir}/#{File.basename(file)}")
      @file_data = x2t.convert("#{@tmp_dir}/#{File.basename(file)}", :pptx)
      expect(File).to exist(@file_data[:tmp_filename])
      next if StaticData::EXCEPTION_FILES['empty_files'].include?(File.basename(file))
    end
  end

  after do |example|
    spec_cleanup(@tmp_dir, @file_data[:tmp_filename])
    # palladium.add_result(example, @file_data)
  end
end
