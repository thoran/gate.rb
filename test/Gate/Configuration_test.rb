require_relative '../helper'

describe Gate::Configuration do
  describe "#initialize" do
    it "sets default values" do
      config = Gate::Configuration.new
      _(config.api_base_url).to eq('https://api.gateio.ws')
      _(config.debug).to eq(false)
      _(config.api_key).must_equal(nil)
      _(config.api_secret).must_equal(nil)
    end
  end
end
