require_relative '../../../helper'

describe Gate::V4::Client do
  let(:api_key){ENV.fetch('GATE_API_KEY', '<API_KEY>')}
  let(:api_secret){ENV.fetch('GATE_API_SECRET', '<API_SECRET>')}

  subject do
    Gate::V4::Client.new(
      api_key: api_key,
      api_secret: api_secret
    )
  end

  describe "#spot_currencies" do
    context "no currency specified" do
      it "fetches all currencies" do
        VCR.use_cassette('v4/spot/currencies') do
          response = subject.spot_currencies
          _(response).must_be_kind_of(Array)
          assert(response.size > 4000)
          _(response[0]['currency']).must_equal('BBC')
        end
      end
    end

    context "currency specified" do
      it "fetches one currency" do
        VCR.use_cassette('v4/spot/currencies_btc') do
          response = subject.spot_currencies('BTC')
          _(response).must_be_kind_of(Hash)
          _(response.size).must_equal(10)
          _(response['currency']).must_equal('BTC')
        end
      end
    end
  end

  describe "#spot_currency_pairs" do
    context "no pair specified" do
      it "fetches data for all markets" do
        VCR.use_cassette('v4/spot/currency_pairs') do
          response = subject.spot_currency_pairs
          _(response).must_be_kind_of(Array)
          assert(response.size > 2000)
          _(response[0]['id']).must_equal('ALEPH_USDT')
          _(response[0]['base']).must_equal('ALEPH')
          _(response[0]['quote']).must_equal('USDT')
        end
      end
    end

    context "pair specified" do
      it "fetches data for one market" do
        VCR.use_cassette('v4/spot/currency_pairs_btc') do
          response = subject.spot_currency_pairs('BTC_USDT')
          _(response).must_be_kind_of(Hash)
          _(response.size).must_equal(18)
          _(response['id']).must_equal('BTC_USDT')
          _(response['base']).must_equal('BTC')
          _(response['quote']).must_equal('USDT')
        end
      end
    end
  end

  describe "#spot_tickers" do
    context "no ticker specified" do
      it "fetches tickers for all markets" do
        VCR.use_cassette('v4/spot/tickers') do
          response = subject.spot_tickers
          _(response).must_be_kind_of(Array)
          assert(response.size > 2000)
          _(response[0]['currency_pair']).must_equal('BAND_USDT')
          assert(response[0]['last'].match(/\d+\.\d*/))
          assert(response[0]['change_percentage'].match(/\d+\.\d*/))
        end
      end
    end

    context "ticker specified" do
      it "fetches ticker for a specific market" do
        VCR.use_cassette('v4/spot/tickers_btc') do
          response = subject.spot_tickers(currency_pair: 'BTC_USDT')
          _(response).must_be_kind_of(Array)
          _(response[0]['currency_pair']).must_equal('BTC_USDT')
          assert(response[0]['last'].match(/\d+\.\d*/))
          assert(response[0]['change_percentage'].match(/\d+\.\d*/))
        end
      end
    end
  end

  describe "#spot_order_book" do
    it "retrieves order book for a specific market" do
      VCR.use_cassette('v4/spot/order_book') do
        response = subject.spot_order_book(currency_pair:'BTC_USDT', limit: 10)
        _(response).must_be_kind_of(Hash)
        _(response['asks'].size).must_equal(10)
        _(response['bids'].size).must_equal(10)
        _(response['asks']).must_be_kind_of(Array)
        _(response['bids']).must_be_kind_of(Array)
        assert(response['asks'].first.first.match(/\d+\.*\d*/))
        assert(response['asks'].first.last.match(/\d+\.*\d*/))
        assert(response['bids'].first.first.match(/\d+\.*\d*/))
        assert(response['bids'].first.last.match(/\d+\.*\d*/))
      end
    end
  end

  describe "#spot_trades" do
    it "fetches recent trades for a given market" do
      VCR.use_cassette('v4/spot/trades') do
        response = subject.spot_trades(currency_pair: 'BTC_USDT', limit: 10)
        _(response).must_be_kind_of(Array)
        _(response.size).must_equal(10)
        assert(response[0]['id'].match(/\d+\.*\d*/))
        assert(response[0]['side'] == 'buy' || response[0]['side'] == 'sell')
        assert(response[0]['amount'].match(/\d+\.*\d*/))
        assert(response[0]['price'].match(/\d+\.*\d*/))
      end
    end
  end

  describe "#spot_candlesticks" do
    it "fetches candlestick data for a specific market" do
      VCR.use_cassette('v4/spot/candlesticks') do
        response = subject.spot_candlesticks(currency_pair: 'BTC_USDT', interval: '1h', limit: 10)
        _(response).must_be_kind_of(Array)
        _(response.size).must_equal(10)
        _(response[0].size).must_equal(8)
        assert(response[0][0].match(/\d+\.*\d*/))
        assert(response[0][1].match(/\d+\.*\d*/)) # open
        assert(response[0][4].match(/\d+\.*\d*/)) # close
      end
    end
  end

  describe "#spot_time" do
    it "fetches candlestick data for a specific market" do
      VCR.use_cassette('v4/spot/time') do
        response = subject.spot_time
        _(response).must_be_kind_of(Hash)
        assert(response['server_time'].to_s.match(/\d+\.*\d*/))
      end
    end
  end
end
