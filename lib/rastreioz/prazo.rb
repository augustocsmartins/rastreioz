require 'net/https'
require 'json'
require 'uri'

module Rastreioz
  class Prazo

    attr_accessor :cep_origem, :cep_destino
    attr_accessor :diametro, :mao_propria, :aviso_recebimento, :valor_declarado
    attr_accessor :codigo_empresa, :senha
    attr_accessor :peso, :comprimento, :largura, :altura, :formato

    DEFAULT_OPTIONS = {
      :peso => 0.0,
      :comprimento => 0.0,
      :largura => 0.0,
      :altura => 0.0,
      :diametro => 0.0,
      :formato => :caixa_pacote,
      :mao_propria => false,
      :aviso_recebimento => false,
      :valor_declarado => 0.0
    }

    URL = "https://api.rastreioz.com/frete/prazo"
    FORMATS = { :caixa_pacote => 1, :rolo_prisma => 2, :envelope => 3 }
    CONDITIONS = { true => "S", false => "N" }

    def initialize(options = {})
      DEFAULT_OPTIONS.merge(options).each do |attr, value|
        self.send("#{attr}=", value)
      end
    end

    def calcular(service_types)
      response = with_log { http_request("#{URL}?#{params_for(service_types)}") }
      response_body = JSON.parse(response.body)

      servicos = {}
      response_body.each do |element|
        servico = Rastreioz::Servico.new.parse(element)
        servicos[servico.tipo] = servico
      end
      servicos

    end

    def self.calcular(service_types, options = {})
      self.new(options).calcular(service_types)
    end

    private

    def http_request(url)
      @uri = URI.parse(url)
      @http = build_http

      request = Net::HTTP::Get.new(uri)
      http.open_timeout = Rastreioz.request_timeout
      http.request(request)
    end

    def params_for(service_types)
      "sCepOrigem=#{self.cep_origem}&" +
      "sCepDestino=#{self.cep_destino}&" +
      "nVlPeso=#{self.peso}&" +
      "nVlComprimento=#{format_decimal(self.comprimento)}&" +
      "nVlLargura=#{format_decimal(self.largura)}&" +
      "nVlAltura=#{format_decimal(self.altura)}&" +
      "nVlDiametro=#{format_decimal(self.diametro)}&" +
      "nCdFormato=#{FORMATS[self.formato]}&" +
      "sCdMaoPropria=#{CONDITIONS[self.mao_propria]}&" +
      "sCdAvisoRecebimento=#{CONDITIONS[self.aviso_recebimento]}&" +
      "nVlValorDeclarado=#{format_decimal(format("%.2f" % self.valor_declarado))}&" +
      "nCdServico=#{service_codes_for(service_types)}&" +
      "nCdEmpresa=#{self.codigo_empresa}&" +
      "sDsSenha=#{self.senha}"
    end

    def format_decimal(value)
      value.to_s
    end

    def service_codes_for(service_types)
      service_types.map { |type| Rastreioz::Servico.code_from_type(type) }.join(",")
    end

    def code_from_type(type)
      # I don't use select method for Ruby 1.8.7 compatibility.
      AVAILABLE_SERVICES.map { |key, value| key if value[:type] == type }.compact.first
    end

    def with_log
      Rastreioz.log format_request_message
      response = yield
      Rastreioz.log format_response_message(response)
      response
    end

    def format_request_message
      message =  with_line_break { "RastreioZ Request:" }
      message << with_line_break { "GET #{@url}" }
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

    attr_reader :uri, :http

  end
end
