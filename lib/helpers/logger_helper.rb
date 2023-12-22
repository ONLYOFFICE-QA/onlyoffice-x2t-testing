# frozen_string_literal: true

class LoggerHelper
  def self.print_to_log(string, color_code = nil)
    message = "#{Time.now.strftime('%T/%d.%m.%y')}    [#{caller[0].to_s[/\w+.rb/].chomp('.rb')}] #{string}"
    color_code ? (puts colorize message, color_code) : (puts message)
  end

  def self.colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end
end
