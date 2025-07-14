# GateIo.rb
# GateIo

# 20241027
# 0.0.3

# Changes:
# 0/1
# 1. ~ spot_currencies: + currency argument
# 1/2
# 2. + spot_currency_pairs()
# 2/3
# 3. + spot_tickers()

require 'Hash/to_parameter_string'
gem 'http.rb'
require 'http.rb'
require 'json'
require 'openssl'

class GateIo
  module V4
    class Client
      API_HOST = 'api.gateio.ws'

      class << self
        def path_prefix
          '/api/v4'
        end
      end # class << self

      def spot_currencies(currency = nil)
        do_request(path: "/spot/currencies/#{currency}")
      end

      def spot_currency_pairs(currency_pair = nil)
        do_request(path: "/spot/currency_pairs/#{currency_pair}")
      end

      def spot_tickers(currency_pair: nil, timezone: nil)
        do_request(
          path: '/spot/tickers',
          args: {currency_pair: currency_pair, timezone: timezone}
        )
      end

      private

      def initialize(api_key:, api_secret:)
        @api_key = api_key.encode('UTF-8')
        @api_secret = api_secret.encode('UTF-8')
      end

      def full_path(path)
        self.class.path_prefix + path
      end

      def encoded_payload
        Digest::SHA512.hexdigest('')
      end

      def timestamp
        @timestamp ||= Time.now.to_i.to_s
      end

      def message(path:, args:)
        ['GET', full_path(path), args.to_parameter_string, encoded_payload, timestamp].join("\n")
      end

      def signature(message)
        OpenSSL::HMAC.hexdigest('SHA512', @api_secret, message)
      end

      def request_string(path)
        "https://#{API_HOST}#{self.class.path_prefix}#{path}"
      end

      def headers(signature)
        {
          'Accept' => 'application/json',
          'Content-type' => 'application/json',
          'KEY' => @api_key,
          'SIGN' => signature,
          'Timestamp' => timestamp,
        }
      end

      def do_request(path:, args: {})
        message = message(path: path, args: args)
        signature = signature(message)
        response = HTTP.get(request_string(path), args, headers(signature))
        JSON.parse(response.body)
      end
    end
  end
end
