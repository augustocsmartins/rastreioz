# encoding: UTF-8
require 'rubygems'
require 'log-me'
require 'net/https'
require 'json'
require 'uri'
require 'crack'
require "rastreioz/app/log"
require "rastreioz/app/http"
require "rastreioz/app/auth"
require "rastreioz/app/servico"
require "rastreioz/app/frete"
require "rastreioz/app/rastreamento"
require "rastreioz/app/calcula_frete"
require "rastreioz/app/cep"
require "rastreioz/engine"
require "rastreioz/version"

module Rastreioz
  extend LogMe

  def self.table_name_prefix
    'rastreioz_'
  end

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
      "http://ws.correios.com.br"
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
