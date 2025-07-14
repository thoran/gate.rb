# Gate/V4/Client.rb
# Gate::V4::Client

# 20250714
# 0.1.0

# Notes:
# 1. API methods appear in the order in which they appear in the documentation.

gem 'http.rb'; require 'http.rb'
require 'json'
require 'openssl'

require 'Gate/Error'
require 'Hash/stringify_values'
require 'Hash/x_www_form_urlencode'

module Gate
  module V4
    class Client

      API_HOST = 'api.gateio.ws'

      class << self
        def path_prefix
          '/api/v4'
        end
      end # class << self

      # Public endpoints

      def spot_currencies(currency = nil)
        response = get(
          path: "/spot/currencies/#{currency}"
        )
        handle_response(response)
      end

      def spot_currency_pairs(currency_pair = nil)
        response = get(
          path: "/spot/currency_pairs/#{currency_pair}"
        )
        handle_response(response)
      end

      def spot_tickers(currency_pair: nil, timezone: nil)
        response = get(
          path: '/spot/tickers',
          args: {currency_pair: currency_pair, timezone: timezone}
        )
        handle_response(response)
      end

      def spot_order_book(
        currency_pair:,
        interval: nil,
        limit: nil,
        with_id: nil
      )
        response = get(
          path: '/spot/order_book',
          args: {
            currency_pair: currency_pair,
            interval: interval,
            limit: limit,
            with_id: with_id
          }
        )
        handle_response(response)
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
        response = get(
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
        handle_response(response)
      end

      def spot_candlesticks(
        currency_pair:,
        limit: nil,
        from: nil,
        to: nil,
        interval: nil
      )
        response = get(
          path: '/spot/candlesticks',
          args: {
            currency_pair: currency_pair,
            limit: limit,
            from: from,
            to: to,
            interval: interval
          }
        )
        handle_response(response)
      end

      def spot_time
        response = get(
          path: '/spot/time'
        )
        handle_response(response)
      end

      def spot_orders(
        text: nil,
        currency_pair:,
        type: nil,
        account: nil,
        side:,
        amount:,
        price: nil,
        time_in_force: nil,
        iceberg: nil
      )
        args = {
          text: text,
          currency_pair: currency_pair,
          type: type,
          account: account,
          side: side,
          amount: amount,
          price: price,
          time_in_force: time_in_force,
          iceberg: iceberg
        }.reject{|k,v| v.nil?}.stringify_values
        response = post(
          path: '/spot/orders',
          args: args
        )
        handle_response(response)
      end

      private

      def initialize(api_key:, api_secret:)
        @api_key = api_key.encode('UTF-8')
        @api_secret = api_secret.encode('UTF-8')
      end

      def full_path(path)
        self.class.path_prefix + path
      end

      def encoded_payload(args)
        args.reject!{|k,v| v.nil?}
        OpenSSL::Digest::SHA512.hexdigest(JSON.dump(args))
      end

      def timestamp
        @timestamp ||= Time.now.to_i.to_s
      end

      def message(verb:, path:, args:)
        query_string = (
          case verb
          when 'GET'
            args.x_www_form_urlencode
          when 'POST'
            nil
          else
            raise "The verb, #{verb}, is not acceptable."
          end
        )
        [verb, full_path(path), query_string, encoded_payload(args), timestamp].join("\n")
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
          'Content-Type' => 'application/json',
          'KEY' => @api_key,
          'SIGN' => signature,
          'Timestamp' => timestamp,
        }
      end

      def do_request(verb:, path:, args: {})
        message = message(verb: verb, path: path, args: args)
        signature = signature(message)
        response = HTTP.send(verb.to_s.downcase, request_string(path), args, headers(signature))
        @timestamp = nil
        response
      end

      def get(path:, args: {})
        do_request(verb: 'GET', path: path, args: args)
      end

      def post(path:, args: {})
        do_request(verb: 'POST', path: path, args: args)
      end

      def handle_response(response)
        if response.success?
          JSON.parse(response.body)
        else
          case response.code.to_i
          when 400
            raise Gate::InvalidRequestError.new(
              code: response.code,
              message: response.message,
              body: response.body
            )
          when 401
            raise Gate::AuthenticationError.new(
              code: response.code,
              message: response.message,
              body: response.body
            )
          when 429
            raise Gate::RateLimitError.new(
              code: response.code,
              message: response.message,
              body: response.body
            )
          else
            raise Gate::APIError.new(
              code: response.code,
              message: response.message,
              body: response.body
            )
          end
        end
      end
    end
  end
end
