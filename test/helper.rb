require 'minitest/autorun'
require 'minitest/spec'
require 'minitest-spec-context'
require 'vcr'
require 'webmock'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'gate'

VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock

  config.filter_sensitive_data('<API_KEY>'){ENV['GATE_API_KEY']}
  config.filter_sensitive_data('<API_SECRET>'){ENV['GATE_API_SECRET']}

  # Allow localhost connections for debugging
  config.ignore_localhost = true

  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }
end

class Minitest::Test
  def before_setup
    super
    Gate.reset_configuration!
  end
end
