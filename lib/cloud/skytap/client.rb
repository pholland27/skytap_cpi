require 'httpclient'

module SkytapCloud

  class Client

    attr_accessor :http_client

    def initialize(host, username, password, options = {})
      @base_uri = 'https://' + host

      @http_client = HTTPClient.new
      @http_client.send_timeout = 14400
      @http_client.receive_timeout = 14400
      @http_client.connect_timeout = 4
      @http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE

      @http_client.set_auth(@base_uri, username, password)
    end

    def get(path)
      @http_client.get(@base_uri + path + '.json', :follow_redirect=>true)
    end
  end

end
