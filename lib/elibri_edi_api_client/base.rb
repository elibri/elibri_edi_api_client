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
      attr_accessor :config_base_url, :config_api_key
    end
    def self.setup(&block)
      yield self
    end
    #/configuration

    attr_reader :response_data, :response_headers

    def initialize(id_or_data)
      if id_or_data.is_a? Integer || id_or_data.to_i.to_s == id_or_data
        @id = id_or_data.to_i
      elsif id_or_data.is_a? Hash
        @data = id_or_data
        @id = @data[:id] if @data[:id]
      else
        fail InputDataError, "Please give integer id or hash of data"
      end
    end

    def session
      @sesssion || new_session
    end

    def post(url)
      _post url, @data
    end

    def get(url_template)
      @request_data = @data.dup if @data
      _get(url_for(url_template))
    end

    def put(url_template)
      @request_data = @data.dup if @data
      _put url_for(url_template), @data
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
      @data[:id]
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
          req.headers = req.headers.merge(headers)
          req.headers = req.headers.merge('Content-Type' => 'application/json')
        end
      end
    end

    def _put(path, data, headers={})
      make_safe_request(path) do
        session.put(path) do |req|
          req.headers = req.headers.merge(headers)
          req.headers = req.headers.merge('Content-Type' => 'application/json')
          data = JSON.dump data unless String === data
          req.body = data
        end
      end
    end

    def _post(path, data, headers={})
      make_safe_request(path) do
        session.post(path) do |req|
          req.headers = req.headers.merge(headers)
          req.headers = req.headers.merge('Content-Type' => 'application/json')
          data = JSON.dump data unless String === data
          req.body = data
        end
      end
    end

    def delete(path, headers={})
      make_safe_request(path) do
        session.delete(path) do |req|
          req.headers = req.headers.merge(headers)
          req.headers = req.headers.merge('Content-Type' => 'application/json')
        end
      end
    end

    def reconnect
      @session = new_session
    end

    def make_safe_request(path, &block)
      res =
        begin
          block.call
        rescue Faraday::TimeoutError
          raise TimeoutError.new("Timed out getting #{full_url(path)}")
        rescue Faraday::ConnectionFailed
          begin
            reconnect
            block.call
          rescue Faraday::ConnectionFailed
            raise ConnectionFailedError.new("Unable to connect to #{full_url(path)}")
          end
        end
      process_response res
    end

    def process_response(response)

      if response.status.to_s[0] == '2' #status 200 (GET OK) lub 201 (created OK)
        json = JSON.parse response.body, symbolize_names: true
        @response_headers = response.headers
        @response_data = json
        @data = @response_data
        if response.status == 201 #created
          @id = @response_data[:id]
        end
      else
        begin
          json = JSON.parse response.body, symbolize_names: true
        rescue JSON::ParserError 
          fail "api call returned invalid data: #{response.body}"
        end
        #TODO: wyświetlać lub przekazywać dalej pełną informację o błędach validacji. Format response jest taki:
        # {:message=>"Validation failed", :errors=>[{:field=>"external_order_id", :message=>"zostało już zajęte"}]}
        if json[:message] && json[:errors]
          fail "api call failed with code: #{response.status} and message: #{json[:message]}\n" +
               "errors: #{json[:errors].inspect}"
        elsif json[:message]
          fail "api call failed with code: #{response.status} and message: #{json[:message]}"
        else
          fail "api call failed with code: #{response.status} and body: #{json.inspect}"
        end
      end
    end

    private
    #FIXME: Najlepiej byłoby udostępnić na zewnątrz możliwość budowania obiektu @session
    # (w sieci raczej używa się nazwy connection), tak aby to wykorzystujący naszego klienta
    # sam decydował, czy chce w danym momencie używać czy testować
    def new_session
      if Rails.env == 'test'
        # Faraday.new(url: ::ElibriEdiApiClient::Base.config_base_url) do |config|
        Faraday.new do |builder|
          builder.use Faraday::Request::BasicAuthentication, 'api', ::ElibriEdiApiClient::Base.config_api_key 
          builder.adapter :rack, ::API::V1::GrapeServer.new
        end
      else
        Faraday.new(url: ::ElibriEdiApiClient::Base.config_base_url) do |builder|
          builder.request :basic_authentication, 'api', ::ElibriEdiApiClient::Base.config_api_key 
        end
      end
    end

    def full_url(path)
      session.build_url(path).to_s
    end


  end


  class Error < StandardError; end
  class TimeoutError < ElibriEdiApiClient::Error; end
  class ConnectionFailedError < ElibriEdiApiClient::Error; end
  class InputDataError < ElibriEdiApiClient::Error; end
end
