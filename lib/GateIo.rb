# GateIo.rb
# GateIo

# 20250207
# 0.0.10

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
# 8/9
# 9. + spot_orders()
# 9/10 (Code hygeine only.)
# 10. ~ do_request(): Use send instead of a case expresssion.
# 11. + get(): A convenience method for do_request().
# 12. + postt(): A convenience method for do_request().
# 13. ~ spot_currencies(): Use get().
# 14. ~ spot_currency_pairs(): Use get().
# 15. ~ spot_tickers(): Use get().
# 16. ~ spot_order_book(): Use get().
# 17. ~ spot_trades(): Use get().
# 18. ~ spot_candlesticks(): Use get().
# 19. ~ spot_my_trades(): Use get().
# 20. ~ spot_time(): Use get().
# 21. ~ spot_orders(): Use post().
# 22. /class GateIo/module GateIo/ (Not sure why it was a class.)
# 23. + GateIo::Client

# Notes:
# 1. API methods appear in the order in which they appear in the documentation.

require 'Hash/to_parameter_string'
gem 'http.rb'
require 'http.rb'
require 'json'
require 'openssl'

module GateIo
  module V4
    class Client
      API_HOST = 'api.gateio.ws'

      class << self
        def path_prefix
          '/api/v4'
        end
      end # class << self

      def spot_currencies(currency = nil)
        get(
          path: "/spot/currencies/#{currency}"
        )
      end

      def spot_currency_pairs(currency_pair = nil)
        get(
          path: "/spot/currency_pairs/#{currency_pair}"
        )
      end

      def spot_tickers(currency_pair: nil, timezone: nil)
        get(
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
        get(
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
        get(
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
        get(
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
        get(
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
        get(
          path: '/spot/time'
        )
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
        post(
          path: '/spot/orders',
          args: {
            text: text,
            currency_pair: currency_pair,
            type: type,
            account: account,
            side: side,
            amount: amount,
            price: price,
            time_in_force: time_in_force,
            iceberg: iceberg
          }
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
            args.to_parameter_string
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
        JSON.parse(response.body)
      end

      def get(path:, args: {})
        do_request(verb: 'GET', path: path, args: args)
      end

      def post(path:, args: {})
        do_request(verb: 'POST', path: path, args: args)
      end
    end
  end

  class Client < GateIo::V4::Client; end
end
