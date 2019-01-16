require 'pstore'
require 'tmpdir'

module Rastreioz
  class Auth

    def token(use_ssl = true)

      auth_token = nil
      if !Rastreioz.api_key.nil? && !Rastreioz.api_password.nil?
        temp_dir = Rails.root.join('tmp') rescue Dir.tmpdir()
        store = PStore.new("#{temp_dir}/pstore.data")

        auth_token = store.transaction { store[:auth_token] }
        expires_in = store.transaction { store[:expires_in] }
        
        if auth_token.nil? || Time.now.to_i > expires_in.to_i
          uri = URI.parse("#{Rastreioz.default_url}/users/login")
          http = Net::HTTP.start(uri.host, uri.port, nil, nil, nil, nil, use_ssl: use_ssl, verify_mode: OpenSSL::SSL::VERIFY_NONE)
          request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/x-www-form-urlencoded'})
          request.body = {api_key: Rastreioz.api_key, api_password: Rastreioz.api_password}.to_json
          response = Rastreioz::Log.new.with_log {
            http.request(request)
          }
          response_body = JSON.parse(response.body)
          auth_token = response_body["auth_token"]
          store.transaction do
            store[:auth_token] = auth_token
            store[:expires_in] = Time.now + 23*60*60
          end
        end
        auth_token
      end

    end

  end
end
