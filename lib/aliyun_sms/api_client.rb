module AliyunSms
  class ApiClient
    API_GATEWAY = "http://dysmsapi.aliyuncs.com".freeze

    attr_reader :access_key_id, :access_key_secret

    def initialize(access_key_id, access_key_secret)
      @access_key_id = access_key_id
      @access_key_secret = access_key_secret
    end

    def send_message(phone_numbers, template_code, template_param, options = {})
      request_params = {
        AccessKeyId: access_key_id,
        Timestamp: Time.now.utc.strftime("%FT%TZ"),
        SignatureMethod: "HMAC-SHA1",
        SignatureVersion: "1.0",
        SignatureNonce: Time.now.utc.strftime("%Y%m%d%H%M%S%L"),
        Action: "SendSms",
        Version: "2017-05-25",
        Format: "JSON",
        RegionId: (options[:region_id] || "cn-hangzhou"),
        PhoneNumbers: phone_numbers,
        SignName: (options[:sign_name] || ""),
        TemplateCode: template_code,
        TemplateParam: (template_param.is_a?(String) ? template_param : template_param.to_json)
      }.tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} send_message response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
      # Hash.from_xml(resp.body)["SendSmsResponse"]
    end

    def sign(sign_params, http_method = "POST")
      key = "#{access_key_secret}&"
      data = "#{http_method.upcase}&%2F&#{ERB::Util.url_encode(sign_params.to_query.gsub('+', '%20'))}"
      Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', key, data))
    end

    private

      def connection(extra_headers: {})
        Faraday.new(
          url: API_GATEWAY,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          }.merge(extra_headers).compact
        )
      end
  end
end
