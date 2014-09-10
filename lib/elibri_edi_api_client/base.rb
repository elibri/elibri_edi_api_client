# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  MESSAGE_KIND_MAPPING = {
    'ORDER' => 'ElibriEdiApiClient::PurchaseOrder',
    'ORDRSP' => 'ElibriEdiApiClient::OrderResponse',
    'DESADV' => 'ElibriEdiApiClient::DespatchAdvice',
    'RECADV' => 'ElibriEdiApiClient::ReceiveAdvice',
    'INVOICE' => 'ElibriEdiApiClient::Invoice',
    'FILE' => 'ElibriEdiApiClient::InputFile'
  }

  class Base

    #configuration
    class << self
      attr_accessor :config_base_url, :config_api_key, :config_secret_key
    end
    def self.setup(&block)
      yield self
    end
    #/configuration

    attr_reader :response_data, :response_headers, :data

    def initialize(id_or_data)
      if id_or_data.is_a? Integer || id_or_data.to_i.to_s == id_or_data
        @id = id_or_data.to_i
      elsif id_or_data.is_a? Hash
        @data = id_or_data
        @id = @data[:id] if @data[:id]
      elsif id_or_data.respond_to?(:to_edi_message)
        @data = id_or_data.to_edi_message
        @id = @data[:id] if @data[:id]
      else
        raise InputDataError.new status: nil, result: "Please give integer id, hash of data or edi data Factory", url: full_url(path)
      end
    end

    def session
      @sesssion ||= self.class.new_session
    end

    def post(url_template, headers = {})
      _post url_for(url_template), @data, headers
    end

    def get(url_template)
      _get(url_for(url_template))
    end

    def put(url_template, headers = {})
      _put url_for(url_template), @data, headers
    end

    def url_for(url_template)
      url_template.gsub(/:id/, @id.to_s)
    end

    def read
      o = self.class.find @id
      @data = o.response_data
      @response_data = @data
      @response_headers = o.response_headers
      self
    end

    def [](attr)
      @data[attr]
    end

    def []=(attr, v)
      @data[attr] = v 
    end

    def id
      @id
    end

    def self.def_attributes(*attributes)
      attributes.each do |attr|
        define_method attr do
          @data[attr.to_sym]
        end
      end
    end

    def self.klass_from_kind(kind)
      MESSAGE_KIND_MAPPING[kind].constantize
    end

    def self.kind_from_klass(klass)
      MESSAGE_KIND_MAPPING.invert[klass.to_s]
    end

    def klass_from_kind(kind)
      self.class.klass_from_kind kind
    end

    def kind_from_klass(klass)
      self.class.kind_from_klass klass
    end

    private
    def _get(path, headers={})
      make_safe_request(path) do
        session.get(path) do |req|
          req.headers = req.headers.merge('Content-Type' => 'application/json')
          req.headers = req.headers.merge(headers)
        end
      end
    end

    def _put(path, data, headers={})
      make_safe_request(path) do
        session.put(path) do |req|
          req.headers = req.headers.merge('Content-Type' => 'application/json')
          req.headers = req.headers.merge(headers)
          data = JSON.dump data unless String === data
          req.body = data
        end
      end
    end

    def _post(path, data, headers={})
      make_safe_request(path) do
        session.post(path) do |req|
          req.headers = req.headers.merge('Content-Type' => 'application/json')
          req.headers = req.headers.merge(headers)
          # binding.pry
          data = JSON.dump data unless String === data
          req.body = data
        end
      end
    end

    def delete(path, headers={})
      make_safe_request(path) do
        session.delete(path) do |req|
          req.headers = req.headers.merge('Content-Type' => 'application/json')
          req.headers = req.headers.merge(headers)
        end
      end
    end

    def reconnect
      @session = self.class.new_session
    end

    def make_safe_request(path, &block)
      res =
        begin
          block.call
        rescue Faraday::TimeoutError
          raise TimeoutError.new status: nil, result: "Timed out establishing connection", url: full_url(path)
        rescue Faraday::ConnectionFailed
          begin
            reconnect
            block.call
          rescue Faraday::ConnectionFailed
            raise ConnectionFailedError.new status: nil, result: "Unable to establish connection", url: full_url(path)
          end
        end
      process_response res, path
    end

    def process_response(response, path)

      if response.status.to_s[0] == '2' #status 200 (GET OK) lub 201 (created OK)
        json = JSON.parse response.body, symbolize_names: true
        @response_headers = response.headers
        @response_data = json
        @data = @response_data
        @id = @response_data[:id]
      elsif response.status == 400
        raise BadRequestError.new   status: response.status, result: extract_message(response.body), url: full_url(path)
      elsif response.status == 403
        raise ForbiddenError.new    status: response.status, result: extract_message(response.body), url: full_url(path)
      elsif response.status == 401 #unauthorized
        raise UnauthorizedError.new status: response.status, result: extract_message(response.body), url: full_url(path)
      elsif response.status == 404
        raise NotFoundError.new     status: response.status, result: extract_message(response.body), url: full_url(path)
      elsif (400..499).include? response.status
        raise HTTPClientError.new   status: response.status, result: extract_message(response.body), url: full_url(path)
      elsif (500..599).include? response.status
        raise ServerError.new       status: response.status, result: extract_message(response.body), url: full_url(path)
      end
    end

    protected
    def replace_data(new_data)
      @data = new_data
    end

    private
    #FIXME: Najlepiej byłoby udostępnić na zewnątrz możliwość budowania obiektu @session
    # (w sieci raczej używa się nazwy connection), tak aby to wykorzystujący naszego klienta
    # sam decydował, czy chce w danym momencie używać czy testować
    def self.new_session
      if Rails.env == 'test'
        @server ||= ::API::V1::GrapeServer.new
        Faraday.new do |builder|
          builder.use Faraday::Request::Hmac, ::ElibriEdiApiClient::Base.config_api_key, ::ElibriEdiApiClient::Base.config_secret_key
          builder.adapter :rack, @server
        end
      else
        Faraday.new(url: ::ElibriEdiApiClient::Base.config_base_url) do |builder|
          builder.use Faraday::Request::Hmac, ::ElibriEdiApiClient::Base.config_api_key, ::ElibriEdiApiClient::Base.config_secret_key
          builder.adapter Faraday.default_adapter
        end
      end
    end

    def extract_message(body)
      begin
        json = JSON::parse(body)
        json["message"] ? json["message"] : body
      rescue JSON::ParserError
        return body
      end
    end


    def full_url(path)
      session.build_url(path).to_s
    end

  end

  class Error < StandardError 
    attr_accessor :status, :result, :url

    def initialize(options={})
      self.status = options[:status]
      self.result = options[:result]
      self.url = options[:url]
    end

    def message
      "status: #{status}, result: #{result}, url: #{url}"
    end

  end
  class InsufficientData < StandardError; end
  class TimeoutError < ElibriEdiApiClient::Error; end
  class ConnectionFailedError < ElibriEdiApiClient::Error; end
  class InputDataError < ElibriEdiApiClient::Error; end

  class HTTPError < Error
    attr_accessor :status, :result, :url
    def initialize(options)
      @status = options[:status]
      @result = options[:result]
      @url = options[:url]
    end

    def to_s
      "API call to #{@url} returned with status #{@status} and result:\n#{@result.inspect}"
    end
  end
  class HTTPClientError < HTTPError; end
  class UnauthorizedError < HTTPClientError; end
  class NotFoundError < HTTPClientError; end
  class BadRequestError < HTTPClientError; end
  class ForbiddenError < HTTPClientError; end
  class ServerError < HTTPError; end

end
