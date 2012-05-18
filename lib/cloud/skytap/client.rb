require 'httpclient'
require 'base64'
require 'json'

module SkytapCloud

  class ClientResponse

    attr_reader :code
    attr_reader :body

    def initialize(ret)
      @code = ret.code
      @body = JSON.parse(ret.body)
    end
  end

  class Client

    attr_accessor :http_client

    def initialize(host, username, password, options = {})
      @base_uri = 'https://' + host

      @http_client = HTTPClient.new
      @http_client.send_timeout = 14400
      @http_client.receive_timeout = 14400
      @http_client.connect_timeout = 4
      @http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE

      @auth_headers = {'Authorization' => "Basic #{Base64.encode64(username + ":" + password)}".gsub("\n","")}
    end

    def get(path)
      ret = @http_client.get(@base_uri + path + '.json', :header=>@auth_headers, :follow_redirect=>true)
      ClientResponse.new(ret)
    end

    def post(path, body)
      ret = @http_client.post(@base_uri + path, :body=>JSON.generate(body), :header=>@auth_headers)
      ClientResponse.new(ret)
    end
  end

end
