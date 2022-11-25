# frozen_string_literal: true

require_relative '../app_manager'

# Methods for processing test results conversion and writing results to csv
class ResultHandler
  def initialize(plan_name, run_name)
    @tcm_helper = OnlyofficeTcmHelper::TcmHelper.new(product_name: StaticData::PROJECT_NAME,
                                                     plan_name:,
                                                     suite_name: run_name)
  end

  def add_result(example)
    reports_dir = "#{Dir.pwd}/reports"
    @tcm_helper.parse(example)
    OnlyofficeLoggerHelper.log("Test is #{@tcm_helper.status}")
    return unless @tcm_helper.status.to_s != 'passed'

    OnlyofficeFileHelper::FileHelper.create_folder(reports_dir)
    File.open("#{reports_dir}/#{@tcm_helper.plan_name} #{@tcm_helper.suite_name} errors.csv", 'a') do |file|
      file.write "#{@tcm_helper.case_name};#{@tcm_helper.status};\n"
    end
  end
end

