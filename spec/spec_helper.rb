# frozen_string_literal: true

require_relative '../management'

def s3
  @s3 ||= OnlyofficeS3Wrapper::AmazonS3Wrapper.new(bucket_name: 'conversion-testing-files', region: 'us-east-1')
end

def x2t
  @x2t ||= X2t.new(x2t_path: "#{StaticData::PROJECT_BIN_PATH}/x2t",
                   fonts_path: StaticData::FONTS_PATH,
                   lib_path: StaticData::PROJECT_BIN_PATH,
                   tmp_path: StaticData::TMP_DIR)
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

def spec_cleanup(tmp_source_file, tmp_converted_file)
  FileUtils.rm_rf(Dir.glob(tmp_source_file), secure: true)
  FileUtils.rm_rf(tmp_converted_file, secure: true)
end

def create_tmp_dir
  dirname = "file_#{Time.now.nsec}"
  FileUtils.makedirs("#{StaticData::TMP_DIR}/#{dirname}")
end
