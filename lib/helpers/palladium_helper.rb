# frozen_string_literal: true

require 'palladium'
class PalladiumHelper
  def initialize(plan_name, run_name)
    @tcm_helper = OnlyofficeTcmHelper::TcmHelper.new(product_name: StaticData::PROJECT_NAME,
                                                     plan_name:,
                                                     suite_name: run_name)
    @palladium = Palladium.new(host: StaticData::PALLADIUM_SERVER,
                               token: StaticData.get_palladium_token,
                               product: StaticData::PROJECT_NAME,
                               plan: plan_name,
                               run: run_name)
  end

  def add_result(example, file_data = nil)
    @tcm_helper.parse(example)
    if file_data
      result_message = JSON.parse(@tcm_helper.result_message)
      result_message['describer'] << { value: file_data[:x2t_result], title: 'x2t_output' } if file_data[:x2t_result]
      result_message['describer'] << { value: file_data[:size_before], title: 'size_before (byte)' } if file_data[:size_before]
      result_message['describer'] << { value: file_data[:size_after], title: 'size_after (byte)' } if file_data[:size_after]
      @tcm_helper.result_message = result_message.to_json
    end
    @palladium.set_result(status: @tcm_helper.status.to_s, description: @tcm_helper.result_message, name: @tcm_helper.case_name)
    OnlyofficeLoggerHelper.log("Test is #{@tcm_helper.status}")
    OnlyofficeLoggerHelper.log(get_result_set_link)
  end

  def get_result_set_link
    "http://#{@palladium.host}/product/#{@palladium.product_id}/plan/#{@palladium.plan_id}/run/#{@palladium.run_id}/result_set/#{@palladium.result_set_id}"
  end

  def get_result_sets(status)
    @palladium.get_result_sets(status).map { |set| set['name'] }
  end

  def get_status(example)
    exception = example.exception
    comment = ''
    return [:pending, example.metadata[:execution_result].pending_message] if example.pending

    # custom_fields = init_custom_fields(example)
    if exception.to_s.include?('got:') || exception.to_s.include?('expected:')
      result = :failed
      comment += "\n#{exception.to_s.gsub('got:', "got:\n").gsub('expected:', "expected:\n")}\n"
    elsif exception.to_s.include?('to return') || exception.to_s.include?('expected')
      result = :failed
      comment += "\n#{exception.to_s.gsub('to return ', "to return:\n").gsub(', got ', "\ngot:\n")}"
    elsif exception.nil?
      result = :passed
      comment += "\nOk"
    else
      result = :aborted
      comment += "\n#{exception}"
    end
    [result, comment]
  end
end
