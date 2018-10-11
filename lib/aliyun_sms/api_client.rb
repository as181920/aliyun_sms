module AliyunSms
  class ApiClient
    attr_reader :access_key_id, :access_key_secret

    def initialize(access_key_id, access_key_secret)
      @access_key_id, @access_key_secret = access_key_id, access_key_secret
    end

    def send_message(template_id, params)
      puts "xxx"
    end

    private
  end
end
