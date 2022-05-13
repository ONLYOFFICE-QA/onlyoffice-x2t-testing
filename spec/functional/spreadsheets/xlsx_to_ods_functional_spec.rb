# frozen_string_literal: true

require 'rspec'
palladium = PalladiumHelper.new(x2t.version, 'Xlsx to Ods')
result_sets = palladium.get_result_sets(StaticData::POSITIVE_STATUSES)
files = s3.files_from_folder('xlsx')
describe 'Conversion xlsx files to ods' do
  before do
    @tmp_dir = FileHelper.create_tmp_dir.first
  end

  (files - result_sets.map { |result_set| "xlsx/#{result_set}" }).each do |file|
    next if File.basename(file) == 'сравнение формул.xlsx' # file is too complicated
    next if File.basename(file) == 'Smaller50MB.xlsx' # file is too big

    it File.basename(file) do
      skip('https://bugzilla.onlyoffice.com/show_bug.cgi?id=46633') if File.basename(file) == 'rank_prf-09.xlsx'
      s3.download_file_by_name(file, @tmp_dir)
      @file_data = x2t.convert("#{@tmp_dir}/#{File.basename(file)}", :ods)
      expect(File).to exist(@file_data[:tmp_filename])
    end
  end

  after do |example|
    FileHelper.spec_cleanup(@tmp_dir, @file_data[:tmp_filename])
    palladium.add_result(example, @file_data)
  end
end
