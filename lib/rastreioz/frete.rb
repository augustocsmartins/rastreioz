module Rastreioz
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

    def calcular(service_types)
      servicos = {}
      url = "#{Rastreioz.default_url}/frete/prazo?#{params_for(service_types)}"
      response = Rastreioz::Log.new.with_log {Rastreioz::Http.new.http_request(url)}
      response_body = JSON.parse(response.body)
      response_body.each do |element|
        servico = Rastreioz::Servico.new.parse(element)
        servicos[servico.tipo] = servico
      end
      servicos
    end

    def self.calcular(service_types, options = {})
      self.new(options).calcular(service_types)
    end

    def update(service_types)
      servicos = {}
      url = "#{Rastreioz.default_url}/frete/prazo?#{params_for(service_types)}"
      response = Rastreioz::Log.new.with_log {Rastreioz::Http.new.http_request(url)}
      response_body = JSON.parse(response.body)
      response_body.each do |element|
        servico = Rastreioz::Servico.new.parse(element)
        servicos[servico.tipo] = servico
      end
      servicos
    end

    def self.update(service_types, options = {})
      self.new(options).calcular(service_types)
    end

    private

    def params_for(service_types)
      res = "cep_origem=#{self.cep_origem}&" +
        "cep_destino=#{self.cep_destino}&" +
        "peso=#{self.peso}&" +
        "comprimento=#{format_decimal(self.comprimento)}&" +
        "largura=#{format_decimal(self.largura)}&" +
        "altura=#{format_decimal(self.altura)}&" +
        "diametro=#{format_decimal(self.diametro)}&" +
        "formato=#{FORMATS[self.formato]}&" +
        "mao_propria=#{CONDITIONS[self.mao_propria]}&" +
        "aviso_recebimento=#{CONDITIONS[self.aviso_recebimento]}&" +
        "valor_declarado=#{format_decimal(format("%.2f" % self.valor_declarado))}&" +
        "servicos=#{service_codes_for(service_types)}"

      res = "#{res}&codigo_empresa=#{self.codigo_empresa}&senha=#{self.senha}" if self.codigo_empresa && self.senha
      res
    end

    def format_decimal(value)
      value.to_s
    end

    def service_codes_for(service_types)
      service_codes = service_types.is_a?(Array) ? 
        service_types.map { |type| Rastreioz::Servico.code_from_type(type) }.join(",") :
        Rastreioz::Servico.code_from_type(service_types)
      service_codes
    end

  end
end
