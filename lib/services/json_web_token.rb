module Services
  class JsonWebToken
    class << self
      def encode(payload)
        JWT.encode(payload, Rails.application.credentials[:jwt_secret])
      end

      def decode(payload)
        HashWithIndifferentAccess.new(JWT.decode(payload, Rails.application.credentials[:jwt_secret])[0])
      rescue StandardError
        nil
      end
    end
  end
end
