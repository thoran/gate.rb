# gate.rb

Access the Gate API with Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gate.rb'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install gate.rb
```

## Usage

```ruby
client = Gate::Client.new(
  api_key: 'your_api_key',
  api_secret: 'your_api_secret',
)
```

### Public API Methods

```ruby
# Get all currencies
client.spot_currencies

# Get specific currency
client.spot_currencies('BTC')

# Get all symbol/currency pairs
client.currency_pairs

# Get one symbol/currency pair
client.currency_pairs('BTC_USDT')

# Get all ticker
client.spot_tickers

# Get ticker for one symbol/currency pair
client.spot_tickers(currency_pair: 'BTC_USDT')

# Get order book for a symbol/currency pair
client.spot_order_book(currency_pair: 'BTC_USDT')

# Get order book for a symbol/currency pair
client.spot_trades(currency_pair: 'BTC_USDT')

# Get OHLC for a symbol/currency pair
client.spot_candlesticks(currency_pair: 'BTC_USDT')

# Get OHLC for a symbol for specific period
client.spot_candlesticks('BTC_USDT', interval: '1d', start_time: 1648995780000, end_time: 1649082180000)

# Get server time
client.spot_time
```

### A Private API Method

```ruby
# Get the authenticated user's trades for specific symbol/currency pair
client.spot_orders(currency_pair: 'BTC_USDT')
```

## Contributing

1. Fork it (https://github.com/thoran/gate.rb/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

## License

The gem is available as open source under the terms of the [Ruby License](https://opensource.org/licenses/MIT).
