module AliyunSms
  class ApiClient
    API_GATEWAY = "http://dysmsapi.aliyuncs.com".freeze

    attr_reader :access_key_id, :access_key_secret

    def initialize(access_key_id, access_key_secret)
      @access_key_id = access_key_id
      @access_key_secret = access_key_secret
    end

    def send_message(phone_numbers, template_code, template_param, options = {})
      request_params = common_params(options:).merge(
        Action: "SendSms",
        PhoneNumbers: phone_numbers,
        SignName: (options[:sign_name] || ""),
        TemplateCode: template_code,
        TemplateParam: (template_param.is_a?(String) ? template_param : template_param.to_json)
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} send_message response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
      # Hash.from_xml(resp.body)["SendSmsResponse"]
    end

    def add_sign(name:, source:, remark:, file_list: [])
      request_params = common_params.merge(
        Action: "AddSmsSign",
        SignName: name,
        SignSource: source,
        Remark: remark,
        SignFileList: file_list
      ).then(&method(:flatten)).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} add_sign response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def modify_sign(name:, source:, remark:, file_list: [])
      request_params = common_params.merge(
        Action: "ModifySmsSign",
        SignName: name,
        SignSource: source,
        Remark: remark,
        SignFileList: file_list
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} modify_sign response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def query_sign(name, options: {})
      request_params = common_params(options:).merge(
        Action: "QuerySmsSign",
        SignName: name
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} query_sign response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def delete_sign(name)
      request_params = common_params.merge(
        Action: "DeleteSmsSign",
        SignName: name
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} delete_sign response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def query_sign_list(page: 1, per: 10, options: {})
      request_params = common_params(options:).merge(
        Action: "QuerySmsSignList",
        PageIndex: page,
        PageSize: per
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} query_sign_list response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def add_template(template_type:, name:, content:, remark:)
      request_params = common_params.merge(
        Action: "AddSmsTemplate",
        TemplateType: template_type,
        TemplateName: name,
        TemplateContent: content,
        Remark: remark
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} add_template response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def modify_template(template_type:, name:, template_code:, content:, remark:)
      request_params = common_params.merge(
        Action: "ModifySmsTemplate",
        TemplateType: template_type,
        TemplateName: name,
        TemplateCode: template_code,
        TemplateContent: content,
        Remark: remark
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} modify_template response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def query_template(template_code, options: {})
      request_params = common_params(options:).merge(
        Action: "QuerySmsTemplate",
        TemplateCode: template_code
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} query_template response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def delete_template(template_code)
      request_params = common_params.merge(
        Action: "DeleteSmsTemplate",
        TemplateCode: template_code
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} delete_template response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def query_template_list(page: 1, per: 10, options: {})
      request_params = common_params(options:).merge(
        Action: "QuerySmsTemplateList",
        PageIndex: page,
        PageSize: per
      ).tap { |params| params[:Signature] = sign(params) }
      connection.post("/", request_params)
        .tap { |resp| AliyunSms.logger.info "#{self.class.name} query_template_list response(#{resp.status}): #{resp.body.squish}" }
        .then { |resp| JSON.parse(resp.body) }
    end

    def sign(sign_params, http_method = "POST")
      key = "#{access_key_secret}&"
      data = "#{http_method.upcase}&%2F&#{ERB::Util.url_encode(sign_params.to_query.gsub('+', '%20'))}"
      Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', key, data))
    end

    def official_sign(...)
      official_sdk.sign(...)
    end

    private

      def connection(extra_headers: {})
        Faraday.new(
          url: API_GATEWAY,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded"
          }.merge(extra_headers).compact
        )
      end

      def common_params(options: {})
        {
          AccessKeyId: access_key_id,
          Timestamp: Time.now.utc.strftime("%FT%TZ"),
          SignatureMethod: "HMAC-SHA1",
          SignatureVersion: "1.0",
          SignatureNonce: Time.now.utc.strftime("%Y%m%d%H%M%S%L"),
          Version: "2017-05-25",
          Format: "JSON",
          RegionId: (options[:region_id] || "cn-hangzhou")
        }
      end

      def official_sdk
        @official_sdk ||= OfficialSdk.new(access_key_id, access_key_secret)
      end

      def flatten(params)
        official_sdk.flat_params(params)
      end
  end
end
