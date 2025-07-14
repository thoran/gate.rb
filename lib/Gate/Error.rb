# Gate/Error.rb
# Gate::Error

module Gate
  class Error < RuntimeError
    attr_reader\
      :code,
      :message,
      :body

    def to_s
      "#{self.class} (#{@code}): #{@message}"
    end

    private

    def initialize(code:, message:, body:)
      @code = code
      @message = message
      @body = body
      super(message)
    end
  end

  class APIError < Error; end
  class AuthenticationError < Error; end
  class InvalidRequestError < Error; end
  class NetworkError < Error; end
  class RateLimitError < Error; end
end
