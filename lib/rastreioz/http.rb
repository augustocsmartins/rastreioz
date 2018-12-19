module Rastreioz
  class Http

    def http_request(request_url)
      @uri = URI.parse(request_url)
      @http = build_http

      request = Net::HTTP::Get.new(@uri)
      http.open_timeout = Rastreioz.request_timeout
      http.request(request)
    end

    private 

    def build_http
      Net::HTTP.start(
        uri.host,
        uri.port,
        nil,
        nil,
        nil,
        nil,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      )
    end      

    attr_reader :uri, :url, :http

  end
end
