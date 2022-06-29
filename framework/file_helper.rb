# frozen_string_literal: true

class FileHelper
  # @param [String] tmp_source_file is a path to the temporary folder with source file
  # @param [String] tmp_converted_file is a path to the temporary converted file
  def self.spec_cleanup(tmp_source_file, tmp_converted_file)
    OnlyofficeLoggerHelper.log('Clear tmp files')
    FileUtils.rm_rf(Dir.glob(tmp_source_file), secure: true)
    FileUtils.rm_rf(tmp_converted_file, secure: true)
  end

  def self.create_tmp_dir
    dirname = Time.now.nsec.to_s
    OnlyofficeLoggerHelper.log("Create dir with name #{dirname}")
    FileUtils.makedirs("#{StaticData::TMP_DIR}/#{dirname}")
  end
end
