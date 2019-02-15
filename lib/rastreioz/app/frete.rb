module Rastreioz
  module App
    class Frete

      attr_accessor :codigo_empresa, :senha, :cep_origem, :cep_destino
      attr_accessor :diametro, :mao_propria, :aviso_recebimento, :valor_declarado
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

      FORMATS = { :caixa_pacote => 1, :rolo_prisma => 2, :envelope => 3 }
      CONDITIONS = { true => "S", false => "N" }

      def initialize(options = {})
        DEFAULT_OPTIONS.merge(options).each do |attr, value|
          self.send("#{attr}=", value)
        end
      end

=begin
webservice = Rastreioz::App::Frete.api_frete([:pac_com_contrato, :sedex_com_contrato_1, :sedex_10, { cep_origem: "01154010", cep_destino: "12221150", peso: 0.8, comprimento: 20, altura: 20, largura: 20, codigo_empresa: 15022544, senha: 18203481 })
=end

      def lista_frete(service_types)
        zipcode = self.cep_destino.gsub(/\D/, "").to_i
        servicos = {}
        freights = Rastreioz::Freight.where(service: service_codes_for(service_types)).freight_info(zipcode, self.peso)
        freights.each do |freight|
          servico = Rastreioz::App::Servico.new.parse_from_db(freight, self.valor_declarado)
          servicos[servico.tipo] = servico
        end
        servicos
      end

      def self.lista_frete(service_types, options = {})
        self.new(options).lista_frete(service_types)
      end

      def api_frete(service_types)
        servicos = {}
        begin

          service_codes = service_types.is_a?(Array) ? 
            Rastreioz::App::Frete.new.service_codes_for(service_types).join(",") : service_types

          url = "#{Rastreioz.default_url}/calculador/CalcPrecoPrazo.asmx/CalcPrecoPrazo?#{params_for(service_codes)}"
          response = Rastreioz::App::Log.new.with_log {Rastreioz::App::Http.new.http_request(url, false)}

          if response.code == '200'
            response_body = Crack::XML.parse(response.body)

            # binding.pry

            if response_body["cResultado"].present? && response_body["cResultado"]["Servicos"].present?
              response_body["cResultado"]["Servicos"].each do |element|
                servico = Rastreioz::App::Servico.new.parse_from_xml(element.last)
                servicos[servico.tipo] = servico
              end
            end
          end

        rescue
          servicos = {}
        end
        servicos
      end

      def self.api_frete(service_types, options = {})
        self.new(options).api_frete(service_types)
      end

      def service_codes_for(service_types)
        service_codes = service_types.is_a?(Array) ? 
          service_types.map { |type| Rastreioz::App::Servico.code_from_type(type)} :
          [Rastreioz::App::Servico.code_from_type(service_types)]
        service_codes
      end

      private

      def params_for(service_types)
        res = "sCepOrigem=#{self.cep_origem}&" +
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
          "nCdServico=#{service_types}&" +
          "StrRetorno=json"

        res = "#{res}&nCdEmpresa=#{self.codigo_empresa}&sDsSenha=#{self.senha}" if self.codigo_empresa && self.senha
        res
      end

      def format_decimal(value)
        value.to_s
      end

    end
  end
end
