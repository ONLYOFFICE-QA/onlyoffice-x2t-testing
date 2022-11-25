# frozen_string_literal: true

require 'rspec'
palladium = PalladiumHelper.new(x2t.version, 'Pdf to Docx')
result_sets = palladium.get_result_sets(StaticData::POSITIVE_STATUSES)
files = s3.files_from_folder('pdf')
describe 'Conversion pdf files to docx' do
  before do
    @tmp_dir = create_tmp_dir.first
  end

  (files - result_sets.map { |result_set| "pdf/#{result_set}" }).each do |file|
    it File.basename(file) do
      s3.download_file_by_name(file, @tmp_dir)
      @file_data = x2t.convert("#{@tmp_dir}/#{File.basename(file)}", :docx)
      expect(File).to exist(@file_data[:tmp_filename])
      if StaticData::EXCEPTION_FILES['large_files_after_conversion_pdf_docx'].include?(File.basename(file))
        skip('https://bugzilla.onlyoffice.com/show_bug.cgi?id=57168')
      end
    end
  end

  after do |example|
    spec_cleanup(@tmp_dir, @file_data[:tmp_filename])
    palladium.add_result(example, @file_data)
  end
end
