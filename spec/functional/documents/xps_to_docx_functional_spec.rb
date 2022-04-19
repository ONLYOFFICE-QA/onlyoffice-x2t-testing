# frozen_string_literal: true

require 'rspec'
palladium = PalladiumHelper.new(x2t.version, 'Xps to Docx')
result_sets = palladium.get_result_sets(StaticData::POSITIVE_STATUSES)
files = s3.files_from_folder('xps')
describe 'Conversion xps files to docx' do
  before do
    @tmp_dir = FileHelper.create_tmp_dir.first
  end

  (files - result_sets.map { |result_set| "xps/#{result_set}" }).each do |file|
    it File.basename(file) do
      s3.download_file_by_name(file, @tmp_dir)
      @file_data = x2t.convert("#{@tmp_dir}/#{File.basename(file)}", :docx)
      expect(File).to exist(@file_data[:tmp_filename])
      # skip some broken xps from the OoxmlParser check https://bugzilla.onlyoffice.com/show_bug.cgi?id=56205
      unless StaticData::BROKEN_FILES['broken_xps'].include?(File.basename(file))
        expect(OoxmlParser::Parser.parse(@file_data[:tmp_filename])).to be_with_data
      end
    end
  end

  after do |example|
    FileHelper.delete_tmp(@tmp_dir)
    palladium.add_result(example, @file_data)
  end
end
