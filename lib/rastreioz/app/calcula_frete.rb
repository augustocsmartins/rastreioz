module Rastreioz
  module App
    class CalculaFrete

      attr_accessor :max_weight, :codigo_empresa, :senha, :cep_origem, :cep_destino
      attr_accessor :diametro, :mao_propria, :aviso_recebimento, :valor_declarado
      attr_accessor :peso, :comprimento, :largura, :altura, :formato

      DEFAULT_OPTIONS = {
        :max_weight => 30.0,
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

      def initialize(options = {})
        DEFAULT_OPTIONS.merge(options).each do |attr, value|
          self.send("#{attr}=", value)
        end
      end

      def calcular(service_types)
        service_codes = Rastreioz::App::Frete.new.service_codes_for(service_types)

        service_codes.each do |service_code|
          Rastreioz::App::Servico.zipcode_ranges(service_code).each do |range|
            Rastreioz::App::Servico.weight_ranges(service_code).each do |weight|
              mean_weight = (weight[0] + weight[1]) / 2

              next if mean_weight > self.max_weight

              tries ||= 3
              begin
  
                puts "#{range[:nome]}/#{range[:estado]} (#{range[:tipo]}) na faixa #{range[:faixas][0]} - #{range[:faixas][1]}. Peso: #{mean_weight}"
                webservice = Rastreioz::App::Frete.api_frete(service_code, {
                  cep_origem: self.cep_origem, cep_destino: range[:faixas][2], peso: mean_weight, 
                  comprimento: self.comprimento, altura: self.altura, largura: self.largura, 
                  aviso_recebimento: self.aviso_recebimento, mao_propria: self.mao_propria,
                  codigo_empresa: self.codigo_empresa, senha: self.senha,
                }).first

                unless webservice.nil?
                  tries = 3
                  if webservice[1].valor.to_f > 0 && webservice[1].prazo_entrega.to_i > 0
                    freight = Rastreioz::Freight.find_by(service: service_code, 
                      zipcode_start: range[:faixas][0], zipcode_end: range[:faixas][1],
                      weight_start: weight[0], weight_end: weight[1])

                    if freight.nil?
                      freight = Rastreioz::Freight.create(service: service_code, zipcode_start: range[:faixas][0],
                        zipcode_end: range[:faixas][1], weight_start: weight[0], weight_end: weight[1], 
                        time_cost: webservice[1].prazo_entrega, price: webservice[1].valor, 
                        handling_price: webservice[1].valor_mao_propria, receipt_recognition_price: webservice[1].valor_aviso_recebimento,
                        home_delivery: webservice[1].entrega_domiciliar, delivery_saturday: webservice[1].entrega_sabado)
                    else
                      freight.update(zipcode_start: range[:faixas][0], zipcode_end: range[:faixas][1], weight_start: weight[0],
                        weight_end: weight[1], time_cost: webservice[1].prazo_entrega, price: webservice[1].valor,
                        handling_price: webservice[1].valor_mao_propria, receipt_recognition_price: webservice[1].valor_aviso_recebimento,
                        home_delivery: webservice[1].entrega_domiciliar, delivery_saturday: webservice[1].entrega_sabado)
                    end
                  end
                end

              rescue
                puts "Não foi possível atualizar #{range[:nome]}/#{range[:estado]} (#{range[:tipo]}) na faixa #{range[:faixas][0]} - #{range[:faixas][1]}"
                sleep(1)
                retry unless (tries -= 1).zero?
              end

            end
          end
        end

      end

      def self.calcular(service_types, options = {})
        self.new(options).calcular(service_types)
      end

    end
  end
end
