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

  describe "#wallet_total_balance" do
    let(:amount){0.0001}
    let(:price){100_000}
    let(:side){'buy'}

    context "success" do
      it "fetches my wallet balance for a specific market" do
        VCR.use_cassette('v4/wallet/total_balance') do
          response = subject.wallet_total_balance(currency: 'BTC')
          _(response).must_be_kind_of(Hash)
          assert(response['details'])
          assert(response['details']['delivery'])
          _(response['details']['delivery']['currency']).must_equal('BTC')
          _(response['details']['delivery']['amount']).must_equal('0')
          assert(response['details']['finance'])
          _(response['details']['finance']['currency']).must_equal('BTC')
          _(response['details']['finance']['amount']).must_equal('0')
          assert(response['details']['futures'])
          _(response['details']['futures']['currency']).must_equal('BTC')
          _(response['details']['futures']['amount']).must_equal('0')
        end
      end
    end

    context "invalid key" do
      let(:api_key){'invalid_key'}
      let(:api_secret){'invalid_secret'}

      it "raises an error" do
        VCR.use_cassette('v4/wallet/total_balance_with_an_invalid_key') do
          assert_raises do
            subject.wallet_total_balance(currency: 'BTC')
          end
        end
      end
    end

    context "insufficient permission" do
      let(:api_key){'key_with_insufficient_permission'}
      let(:api_secret){'secret_with_insufficient_permission'}

      it "raises an error" do
        VCR.use_cassette('v4/wallet/total_balance_with_insufficient_permission') do
          assert_raises do
            subject.spot_orders(currency: 'BTC')
          end
        end
      end
    end
  end

  describe "#spot_orders" do
    let(:amount){0.0001}
    let(:price){100_000}
    let(:side){'buy'}

    context "success" do
      it "fetches my orders for a specific market" do
        VCR.use_cassette('v4/spot/orders') do
          response = subject.spot_orders(currency_pair: 'BTC_USDT', side: side, amount: amount, time_in_force: 'gtc', price: price)
          _(response).must_be_kind_of(Hash)
          assert(response['id'])
          assert(response['create_time'])
          _(response['amount']).must_equal(amount.to_s)
          _(response['price']).must_equal(price.to_s)
          _(response['side']).must_equal(side)
        end
      end
    end

    context "invalid key" do
      let(:api_key){'invalid_key'}
      let(:api_secret){'invalid_secret'}

      it "raises an error" do
        VCR.use_cassette('v4/spot/orders_with_an_invalid_key') do
          assert_raises do
            subject.spot_orders(currency_pair: 'BTC_USDT', side: side, amount: amount, time_in_force: 'gtc', price: price)
          end
        end
      end
    end

    context "insufficient permission" do
      let(:api_key){'key_with_insufficient_permission'}
      let(:api_secret){'secret_with_insufficient_permission'}

      it "raises an error" do
        VCR.use_cassette('v4/spot/orders_with_insufficient_permission') do
          assert_raises do
            subject.spot_orders(currency_pair: 'BTC_USDT', side: side, amount: amount, time_in_force: 'gtc', price: price)
          end
        end
      end
    end
  end

  describe "#spot_my_trades" do
    context "success" do
      it "fetches my trading history" do
        VCR.use_cassette('v4/spot/my_trades') do
          response = subject.spot_my_trades(currency_pair: 'BTC5S_USDT')
          _(response).must_be_kind_of(Array)
          _(response.first).must_be_kind_of(Hash)
          assert(response.first['id'])
          assert(response.first['create_time'])
          assert(response.first['currency_pair'])
          assert(response.first['amount'])
          assert(response.first['price'])
          assert(['buy', 'sell'].include?(response.first['side']))
        end
      end
    end

    context "invalid key" do
      let(:api_key){'invalid_key'}
      let(:api_secret){'invalid_secret'}

      it "raises an error" do
        VCR.use_cassette('v4/spot/my_trades_with_an_invalid_key') do
          assert_raises do
            subject.spot_my_trades(currency_pair: 'BTC_USDT')
          end
        end
      end
    end
  end
end
