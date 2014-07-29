require 'faraday'

module Faraday
  class Request::Hmac < Faraday::Middleware

    def initialize(app, token, secret)
      @app, @token, @secret = app, token, secret
    end

    def call(env)
      sign(env)
      @app.call(env)
    end

    def sign(env)
      env.request_headers['Access-Key'] = @token

      timestamp = Time.now.to_i
      env.request_headers['Access-Nonce'] = timestamp.to_s

      #compute signature
      message = timestamp.to_s + env.url.path + env.body.to_s
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret, message)
      env.request_headers['Access-Signature'] = signature
    end

  end
end
