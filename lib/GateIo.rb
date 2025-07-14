# GateIo.rb
# GateIo

# 20250127
# 0.0.8

# Changes:
# 0/1
# 1. ~ spot_currencies: + currency argument
# 1/2
# 2. + spot_currency_pairs()
# 2/3
# 3. + spot_tickers()
# 3/4
# 4. + spot_order_book()
# 4/5
# 5. + spot_trades()
# 5/6
# 6. + spot_candlesticks()
# 6/7
# 7. + spot_my_trades()
# 7/8
# 8. + spot_time()

# Notes:
# 1. API methods appear in the order in which they appear in the documentation.

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
        do_request(
          verb: 'GET',
          path: "/spot/currencies/#{currency}"
        )
      end

      def spot_currency_pairs(currency_pair = nil)
        do_request(
          verb: 'GET',
          path: "/spot/currency_pairs/#{currency_pair}"
        )
      end

      def spot_tickers(currency_pair: nil, timezone: nil)
        do_request(
          verb: 'GET',
          path: '/spot/tickers',
          args: {currency_pair: currency_pair, timezone: timezone}
        )
      end

      def spot_order_book(
        currency_pair:,
        interval: nil,
        limit: nil,
        with_id: nil
      )
        do_request(
          verb: 'GET',
          path: '/spot/order_book',
          args: {
            currency_pair: currency_pair,
            interval: interval,
            limit: limit,
            with_id: with_id
          }
        )
      end

      def spot_trades(
        currency_pair:,
        limit: nil,
        last_id: nil,
        reverse: nil,
        from: nil,
        to: nil,
        page: nil
      )
        do_request(
          verb: 'GET',
          path: '/spot/trades',
          args: {
            currency_pair: currency_pair,
            limit: limit,
            last_id: last_id,
            reverse: reverse,
            from: from,
            to: to,
            page: page
          }
        )
      end

      def spot_candlesticks(
        currency_pair:,
        limit: nil,
        from: nil,
        to: nil,
        interval: nil
      )
        do_request(
          verb: 'GET',
          path: '/spot/candlesticks',
          args: {
            currency_pair: currency_pair,
            limit: limit,
            from: from,
            to: to,
            interval: interval
          }
        )
      end

      def spot_my_trades(
        currency_pair: nil,
        limit: nil,
        page: nil,
        order_id: nil,
        account: nil,
        from: nil,
        to: nil
      )
        do_request(
          verb: 'GET',
          path: '/spot/my_trades',
          args: {
            currency_pair: currency_pair,
            limit: limit,
            page: page,
            order_id: order_id,
            account: account,
            from: from,
            to: to
          }
        )
      end

      def spot_time
        do_request(
          verb: 'GET',
          path: '/spot/time'
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
