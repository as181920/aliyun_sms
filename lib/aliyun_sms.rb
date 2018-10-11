require "erb"
require "openssl"
require "faraday"
require "active_support/all"
require "aliyun_sms/version"
require "aliyun_sms/api_client"

module AliyunSms
  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end
end
