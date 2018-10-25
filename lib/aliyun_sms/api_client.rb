module AliyunSms
  class ApiClient
    attr_reader :access_key_id, :access_key_secret

    def initialize(access_key_id, access_key_secret)
      @access_key_id, @access_key_secret = access_key_id, access_key_secret
    end

    def send_message(phone_numbers, template_code, template_param, options={})
      query_params = {
        AccessKeyId: access_key_id,
        Timestamp: Time.now.utc.strftime("%FT%TZ"),
        SignatureMethod: "HMAC-SHA1",
        SignatureVersion: "1.0",
        SignatureNonce: Time.now.utc.strftime("%Y%m%d%H%M%S%L"),
        Action: "SendSms",
        Version: "2017-05-25",
        RegionId: (options[:region_id] || "cn-hangzhou"),
        PhoneNumbers: phone_numbers,
        SignName: (options[:sign_name] || ""),
        TemplateCode: template_code,
        TemplateParam: template_param
      }.tap do |p|
        key = "#{access_key_secret}&"
        data = "GET&%2F&#{ERB::Util.url_encode(p.to_query.gsub('+', '%20'))}"
        p[:Signature] = Base64.strict_encode64("#{OpenSSL::HMAC.digest("sha1", key, data)}")
      end
      resp = Faraday.get "http://dysmsapi.aliyuncs.com/?#{query_params.to_query}"
      AliyunSms.logger.info "AliyunSms send_message response(#{resp.status}): #{resp.body}"
      Hash.from_xml(resp.body)
    end
  end
end
