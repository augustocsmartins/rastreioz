module Rastreioz
  module App
    class Http

      def http_request(request_url, use_ssl = true)
        @uri = URI.parse(request_url)
        @http = build_http(use_ssl)
        request = Net::HTTP::Get.new(@uri)
        # request['Authorization'] = Rastreioz::App::Auth.new.token(use_ssl)
        http.open_timeout = Rastreioz.request_timeout
        http.request(request)
      end

      private 

      def build_http(use_ssl)
        Net::HTTP.start(uri.host, uri.port, nil, nil, nil, nil, use_ssl: use_ssl, verify_mode: OpenSSL::SSL::VERIFY_NONE)
      end      

      attr_reader :uri, :url, :http

    end
  end
end
