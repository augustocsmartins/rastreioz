# encoding: UTF-8
require 'rubygems'
require 'log-me'
require "rastreioz/version"
require "rastreioz/prazo"

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
end
