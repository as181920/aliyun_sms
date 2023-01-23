module AliyunSms
  class OfficialSdk
    attr_reader :access_key_id, :access_key_secret

    def initialize(access_key_id, access_key_secret)
      @access_key_id = access_key_id
      @access_key_secret = access_key_secret
    end

    def sign(sign_params, http_method = "POST")
      key = access_key_secret + '&'
      normalized = normalize(sign_params)
      canonicalized = canonicalize(normalized)
      string_to_sign = "#{http_method}&#{encode('/')}&#{encode(canonicalized)}"
      Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', key, string_to_sign))
    end

    private

      def encode(string)
        string = string.to_s unless string.is_a?(String)
        encoded = CGI.escape string
        encoded.gsub(/[\+]/, '%20')
      end

      def upcase_first(string)
        string.length > 0 ? string[0].upcase.concat(string[1..-1]) : ""
      end

      def format_params(param_hash)
        param_hash.keys.each { |key| param_hash[upcase_first(key.to_s).to_sym] = param_hash.delete key }
        param_hash
      end

      def replace_repeat_list(target, key, repeat)
        repeat.each_with_index do |item, index|
          if item && item.instance_of?(Hash)
            item.each_key { |k| target["#{key}.#{index.next}.#{k}"] = item[k] }
          else
            target["#{key}.#{index.next}"] = item
          end
        end
        target
      end

      def flat_params(params)
        target = {}
        params.each do |key, value|
          if value.instance_of?(Array)
            replace_repeat_list(target, key, value)
          else
            target[key.to_s] = value
          end
        end
        target
      end

      def normalize(params)
        flat_params(params)
          .sort
          .to_h
          .map { |key, value| [encode(key), encode(value)] }
      end

      def canonicalize(normalized)
        normalized.map { |element| "#{element.first}=#{element.last}" }.join('&')
      end
  end
end
