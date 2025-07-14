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
      it "fetches my orders for a specific market" do
        VCR.use_cassette('v4/spot/orders_with_an_invalid_key') do
          assert_raises do
            subject.spot_orders(currency_pair: 'BTC_USDT', side: side, amount: amount, time_in_force: 'gtc', price: price)
          end
        end
      end
    end
  end
end
