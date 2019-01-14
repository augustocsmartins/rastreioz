module Rastreioz
  class Log

    def with_log
      response = yield
      Rastreioz.log(format_request_message(response))
      Rastreioz.log(format_response_message(response))
      response
    end

    def format_request_message(response)
      message =  with_line_break { "RastreioZ Request:" }
      message << with_line_break { "#{response.uri}" }
    end

    def format_response_message(response)
      message =  with_line_break { "RastreioZ Response:" }
      message << with_line_break { "HTTP/#{response.http_version} #{response.code} #{response.message}" }
      message << with_line_break { format_headers_for(response) } if Rastreioz.log_level == :debug
      message << with_line_break { response.body }
    end

    def format_headers_for(http)
      # I'm using an empty block in each_header method for Ruby 1.8.7 compatibility.
      http.each_header{}.map { |name, values| "#{name}: #{values.first}" }.join("\n")
    end

    def with_line_break
      "#{yield}\n"
    end

  end
end
