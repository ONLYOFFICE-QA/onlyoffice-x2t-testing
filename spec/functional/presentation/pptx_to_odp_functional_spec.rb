# frozen_string_literal: true

require 'rspec'
palladium = PalladiumHelper.new(x2t.version, 'Pptx to Odp')
result_sets = palladium.get_result_sets(StaticData::POSITIVE_STATUSES)
files = s3.files_from_folder('pptx')
describe 'Conversion pptx files to odp' do
  before do
    @tmp_dir = FileHelper.create_tmp_dir.first
  end

  (files - result_sets.map { |result_set| "pptx/#{result_set}" }).each do |file|
    it File.basename(file) do
      s3.download_file_by_name(file, @tmp_dir)
      @file_data = x2t.convert("#{@tmp_dir}/#{File.basename(file)}", :odp)
      expect(File).to exist(@file_data[:tmp_filename])
    end
  end

  after do |example|
    FileHelper.delete_tmp(@tmp_dir)
    palladium.add_result(example, @file_data)
  end
end
