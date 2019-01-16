# encoding: UTF-8
require 'rubygems'
require 'log-me'
require 'net/https'
require 'json'
require 'uri'
require "rastreioz/version"
require "rastreioz/log"
require "rastreioz/http"
require "rastreioz/auth"
require "rastreioz/servico"
require "rastreioz/rastreamento"
require "rastreioz/frete"
require "rastreioz/cep"

module Rastreioz
  extend LogMe

  module Timeout
    DEFAULT_REQUEST_TIMEOUT = 10 #seconds
    attr_writer :request_timeout

    def request_timeout
      (@request_timeout ||= DEFAULT_REQUEST_TIMEOUT).to_i
    end
  end

  extend Timeout

  class << self

    def default_url
      "https://77ykhqqwh8.execute-api.sa-east-1.amazonaws.com/prod"
    end

    def api_key=(api_key)
      @api_key = api_key
    end
    def api_key
      @api_key
    end

    def api_password=(api_password)
      @api_password = api_password
    end
    def api_password
      @api_password
    end
  end

end
