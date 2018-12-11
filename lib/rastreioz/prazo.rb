require 'net/https'
require 'json'
require 'uri'

module Rastreioz
  class Prazo

    attr_accessor :cep_origem, :cep_destino
    attr_accessor :diametro, :mao_propria, :aviso_recebimento, :valor_declarado
    attr_accessor :codigo_empresa, :senha
    attr_accessor :peso, :comprimento, :largura, :altura, :formato

    AVAILABLE_SERVICES = {
      "04510" => { :type => :pac,                         :name => "PAC",            :description => "PAC sem contrato"                  },
      "41068" => { :type => :pac_com_contrato,            :name => "PAC",            :description => "PAC com contrato"                  },
      "04669" => { :type => :pac_com_contrato_2,          :name => "PAC",            :description => "PAC com contrato"                  },
      "41300" => { :type => :pac_gf,                      :name => "PAC GF",         :description => "PAC para grandes formatos"         },
      "04014" => { :type => :sedex,                       :name => "SEDEX",          :description => "SEDEX sem contrato"                },
      "40045" => { :type => :sedex_a_cobrar,              :name => "SEDEX a Cobrar", :description => "SEDEX a Cobrar, sem contrato"      },
      "40126" => { :type => :sedex_a_cobrar_com_contrato, :name => "SEDEX a Cobrar", :description => "SEDEX a Cobrar, com contrato"      },
      "40215" => { :type => :sedex_10,                    :name => "SEDEX 10",       :description => "SEDEX 10, sem contrato"            },
      "40290" => { :type => :sedex_hoje,                  :name => "SEDEX Hoje",     :description => "SEDEX Hoje, sem contrato"          },
      "40096" => { :type => :sedex_com_contrato_1,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "40436" => { :type => :sedex_com_contrato_2,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "40444" => { :type => :sedex_com_contrato_3,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "40568" => { :type => :sedex_com_contrato_4,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "40606" => { :type => :sedex_com_contrato_5,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "04162" => { :type => :sedex_com_contrato_6,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "81019" => { :type => :e_sedex,                     :name => "e-SEDEX",        :description => "e-SEDEX, com contrato"             },
      "81027" => { :type => :e_sedex_prioritario,         :name => "e-SEDEX",        :description => "e-SEDEX Prioritário, com contrato" },
      "81035" => { :type => :e_sedex_express,             :name => "e-SEDEX",        :description => "e-SEDEX Express, com contrato"     },
      "81868" => { :type => :e_sedex_grupo_1,             :name => "e-SEDEX",        :description => "(Grupo 1) e-SEDEX, com contrato"   },
      "81833" => { :type => :e_sedex_grupo_2,             :name => "e-SEDEX",        :description => "(Grupo 2) e-SEDEX, com contrato"   },
      "81850" => { :type => :e_sedex_grupo_3,             :name => "e-SEDEX",        :description => "(Grupo 3) e-SEDEX, com contrato"   }
    }.freeze

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
      response_body
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
      service_types.map { |type| code_from_type(type) }.join(",")
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
