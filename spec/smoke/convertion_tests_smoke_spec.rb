# frozen_string_literal: true

require 'rspec'
palladium = PalladiumHelper.new(x2t.version, 'Conversion tests smoke')

describe 'Conversion tests' do
  before do
    @tmp_dir = FileHelper.create_tmp_dir.first
  end

  StaticData::CONVERSION_STRAIGHT.each_pair do |format_from, formats_to|
    formats_to.each do |format|
      it "Check converting from #{format_from} to #{format}" do
        filepath = "#{StaticData::NEW_FILES_DIR}/new.#{format_from}"
        file_data = x2t.convert(filepath, format)
        expect(File).to exist(file_data[:tmp_filename])
      end
    end
  end

  after do |example|
    FileHelper.delete_tmp(@tmp_dir)
    palladium.add_result(example)
  end

  it 'Check converting from docx to xlsx negative' do
    filepath = "#{StaticData::NEW_FILES_DIR}/new.docx"
    file_data = x2t.convert(filepath, :xlsx)
    expect(File).not_to exist(file_data[:tmp_filename])
  end

  it 'Check conversion errors' do
    filepath = "#{StaticData::BROKEN_FILES_DIR}/It_is_docx_file.xlsx"
    file_data = x2t.convert(filepath, :xlst)
    expect(File).not_to exist(file_data[:tmp_filename])
    expect(file_data[:size_after]).to be_nil
    expect(file_data[:x2t_result]).to eq("Couldn't automatically recognize conversion direction from extensions")
  end
end
