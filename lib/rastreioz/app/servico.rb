# encoding: UTF-8

module Rastreioz
  module App
    class Servico

      AVAILABLE_SERVICES = {
        "4510"  => { :type => :pac,                         :name => "PAC",            :description => "PAC sem contrato"                  },
        "41068" => { :type => :pac_com_contrato,            :name => "PAC",            :description => "PAC com contrato"                  },
        "4669"  => { :type => :pac_com_contrato_2,          :name => "PAC",            :description => "PAC com contrato"                  },
        "41300" => { :type => :pac_gf,                      :name => "PAC GF",         :description => "PAC para grandes formatos"         },
        "4014"  => { :type => :sedex,                       :name => "SEDEX",          :description => "SEDEX sem contrato"                },
        "40045" => { :type => :sedex_a_cobrar,              :name => "SEDEX a Cobrar", :description => "SEDEX a Cobrar, sem contrato"      },
        "40126" => { :type => :sedex_a_cobrar_com_contrato, :name => "SEDEX a Cobrar", :description => "SEDEX a Cobrar, com contrato"      },
        "40215" => { :type => :sedex_10,                    :name => "SEDEX 10",       :description => "SEDEX 10, sem contrato"            },
        "40290" => { :type => :sedex_hoje,                  :name => "SEDEX Hoje",     :description => "SEDEX Hoje, sem contrato"          },
        "40096" => { :type => :sedex_com_contrato_1,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
        "40436" => { :type => :sedex_com_contrato_2,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
        "40444" => { :type => :sedex_com_contrato_3,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
        "40568" => { :type => :sedex_com_contrato_4,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
        "40606" => { :type => :sedex_com_contrato_5,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
        "4162"  => { :type => :sedex_com_contrato_6,        :name => "SEDEX",          :description => "SEDEX com contrato"                }
      }.freeze

      AVAILABLE_METHODS = {
        "Codigo" => "codigo",
        "Valor" => "valor",
        "PrazoEntrega" => "prazo_entrega",
        "ValorMaoPropria" => "valor_mao_propria",
        "ValorAvisoRecebimento" => "valor_aviso_recebimento",
        "ValorValorDeclarado" => "valor_valor_declarado",
        "EntregaDomiciliar" => "entrega_domiciliar",
        "EntregaSabado" => "entrega_sabado",
        "Erro" => "erro",
        "MsgErro" => "msg_erro",
        "obsFim" => "obs_fim"
      }.freeze

      attr_reader :codigo, :valor, :prazo_entrega
      attr_reader :valor_mao_propria, :valor_aviso_recebimento, :valor_valor_declarado, :valor_sem_adicionais
      attr_reader :entrega_domiciliar, :entrega_sabado, :erro, :msg_erro, :obs_fim
      attr_reader :tipo, :nome, :descricao

      def parse_from_db(freight, valor_declarado)
        @codigo = freight.service.to_s

        if AVAILABLE_SERVICES[@codigo]
          @tipo = AVAILABLE_SERVICES[@codigo][:type]
          @nome = AVAILABLE_SERVICES[@codigo][:name]
          @descricao = AVAILABLE_SERVICES[@codigo][:description]
        end

        @valor = freight.price
        @prazo_entrega = freight.time_cost

        @valor_mao_propria = 0.0
        @valor_aviso_recebimento = 0.00
        @valor_valor_declarado = @valor + (valor_declarado * 0.015) # 1,5% sobre o valor total declarado

        @entrega_domiciliar = false
        @entrega_sabado = false
        @erro = nil

        self
      end

      def parse_from_xml(element)

        element.each do |attr, value|
          instance_variable_set("@#{AVAILABLE_METHODS[attr]}", value.to_s) unless AVAILABLE_METHODS[attr].nil?
        end

        if AVAILABLE_SERVICES[codigo]
          @tipo = AVAILABLE_SERVICES[codigo][:type]
          @nome = AVAILABLE_SERVICES[codigo][:name]
          @descricao = AVAILABLE_SERVICES[codigo][:description]
        end

        cast_to_float! :valor, :valor_mao_propria, :valor_aviso_recebimento, :valor_valor_declarado
        cast_to_int! :prazo_entrega
        cast_to_boolean! :entrega_domiciliar, :entrega_sabado

        self
      end

      def success?
        valor > 0.0
      end
      alias sucesso? success?

      def error?
        !success?
      end
      alias erro? error?

      def self.code_from_type(type)
        # I don't use select method for Ruby 1.8.7 compatibility.
        AVAILABLE_SERVICES.map { |key, value| key if value[:type] == type }.compact.first
      end

      def self.zipcode_ranges(service_code)
        ranges = []
        if service_code == "40215" || service_code == "40290"
          ranges = [
            {estado: 'AC', tipo: 'capital', nome: 'Rio Branco', faixas: ['69900000', '69920999', '69911-776']},
            {estado: 'AL', tipo: 'capital', nome: 'Maceió', faixas: ['57000000', '57099999', '57010-003']},
            {estado: 'AM', tipo: 'capital', nome: 'Manaus', faixas: ['69000000', '69099999', '69083-350']},
            {estado: 'AP', tipo: 'capital', nome: 'Macapá', faixas: ['68900000', '68914999', '68909-167']},
            {estado: 'BA', tipo: 'capital', nome: 'Salvador', faixas: ['40000000', '44470999', '40335-505']},
            {estado: 'CE', tipo: 'capital', nome: 'Fortaleza', faixas: ['60000000', '61900999', '60744-280']},
            {estado: 'DF', tipo: 'capital', nome: 'Brasília', faixas: ['70000000', '70999999', '71900-500']},
            {estado: 'DF', tipo: 'capital', nome: 'Brasília', faixas: ['71000000', '73699999', '73090-135']},
            {estado: 'ES', tipo: 'capital', nome: 'Vitória', faixas: ['29000000', '29099999', '29060-017']},
            {estado: 'GO', tipo: 'capital', nome: 'Goiânia', faixas: ['72800000', '74894999', '74343-610']},
            {estado: 'MA', tipo: 'capital', nome: 'São Luiz', faixas: ['65000000', '65099999', '65072-405']},
            {estado: 'MG', tipo: 'capital', nome: 'Belo Horizonte', faixas: ['30000000', '34999999', '31540-473']},
            {estado: 'MS', tipo: 'capital', nome: 'Campo Grande', faixas: ['79000000', '79129999', '79104-570']},
            {estado: 'MT', tipo: 'capital', nome: 'Cuiabá', faixas: ['78000000', '78109999', '78048-245']},
            {estado: 'PA', tipo: 'capital', nome: 'Belém', faixas: ['66000000', '67999999', '66820-820']},
            {estado: 'PB', tipo: 'capital', nome: 'João Pessoa', faixas: ['58000000', '58099999', '58028-860']},
            {estado: 'PE', tipo: 'capital', nome: 'Recife', faixas: ['50000000', '54999999', '52031-216']},
            {estado: 'PI', tipo: 'capital', nome: 'Teresina', faixas: ['64000000', '64099999', '64062-080']},
            {estado: 'PR', tipo: 'capital', nome: 'Curitiba', faixas: ['80000000', '83800999', '80510-330']},
            {estado: 'RJ', tipo: 'capital', nome: 'Rio De Janeiro', faixas: ['20000000', '26600999', '23591-450']},
            {estado: 'RJ', tipo: 'interior', nome: 'Interior do RJ', faixas: ['26601000', '28999999', '28035-005']},
            {estado: 'RN', tipo: 'capital', nome: 'Natal', faixas: ['59000000', '59099999', '59123-029']},
            {estado: 'RN', tipo: 'interior', nome: 'Interior do RN', faixas: ['59100000', '59999999', '59612-300']},
            {estado: 'RO', tipo: 'capital', nome: 'Porto Velho', faixas: ['78900000', '78930999', '76801-016']},
            {estado: 'RR', tipo: 'capital', nome: 'Boa Vista', faixas: ['69300000', '69339999', '69310-030']},
            {estado: 'RS', tipo: 'capital', nome: 'Porto Alegre', faixas: ['90000000', '94900999', '91330-730']},
            {estado: 'RS', tipo: 'interior', nome: 'Interior do RS', faixas: ['94901000', '99999999', '94475-770']},
            {estado: 'SC', tipo: 'capital', nome: 'Florianópolis', faixas: ['88000000', '88469999', '88066-410']},
            {estado: 'SC', tipo: 'interior', nome: 'Interior de SC', faixas: ['88470000', '89999999', '88818-286']},
            {estado: 'SE', tipo: 'capital', nome: 'Aracajú', faixas: ['49000000', '49099999', '49027-390']},
            {estado: 'SP', tipo: 'capital', nome: 'São Paulo', faixas: ['01000000', '09999999', '01303-001']},
            {estado: 'TO', tipo: 'capital', nome: 'Palmas', faixas: ['77000000', '77270999', '77064-318']},
          ]     
        else
          ranges = [
            {estado: 'AC', tipo: 'capital', nome: 'Rio Branco', faixas: ['69900000', '69920999', '69911-776']},
            {estado: 'AC', tipo: 'interior', nome: 'Interior do AC', faixas: ['69921000', '69999999', '69970-000']},
            {estado: 'AL', tipo: 'capital', nome: 'Maceió', faixas: ['57000000', '57099999', '57010-003']},
            {estado: 'AL', tipo: 'interior', nome: 'Interior do AL', faixas: ['57100000', '57999999', '57602-640']},
            {estado: 'AM', tipo: 'capital', nome: 'Manaus', faixas: ['69000000', '69099999', '69083-350']},
            {estado: 'AM', tipo: 'interior', nome: 'Interior do AM', faixas: ['69100000', '69299999', '69280-000']},
            {estado: 'AP', tipo: 'capital', nome: 'Macapá', faixas: ['68900000', '68914999', '68909-167']},
            {estado: 'AP', tipo: 'interior', nome: 'Interior do AP', faixas: ['68915000', '68999999', '68920-000']},
            {estado: 'BA', tipo: 'capital', nome: 'Salvador', faixas: ['40000000', '44470999', '40335-505']},
            {estado: 'BA', tipo: 'interior', nome: 'Interior da BA', faixas: ['44471000', '48999999', '44935-000']},
            {estado: 'CE', tipo: 'capital', nome: 'Fortaleza', faixas: ['60000000', '61900999', '60744-280']},
            {estado: 'CE', tipo: 'interior', nome: 'Interior do CE', faixas: ['61901000', '63999999', '62748-000']},
            {estado: 'DF', tipo: 'capital', nome: 'Brasília', faixas: ['70000000', '70999999', '71900-500']},
            {estado: 'DF', tipo: 'capital', nome: 'Brasília', faixas: ['71000000', '73699999', '73090-135']},
            {estado: 'ES', tipo: 'capital', nome: 'Vitória', faixas: ['29000000', '29099999', '29060-017']},
            {estado: 'ES', tipo: 'interior', nome: 'Interior do ES', faixas: ['29100000', '29999999', '29860-000']},
            {estado: 'GO', tipo: 'capital', nome: 'Goiânia', faixas: ['72800000', '74894999', '74343-610']},
            {estado: 'GO', tipo: 'interior', nome: 'Interior de GO', faixas: ['74895000', '76799999', '76330-000']},
            {estado: 'MA', tipo: 'capital', nome: 'São Luiz', faixas: ['65000000', '65099999', '65072-405']},
            {estado: 'MA', tipo: 'interior', nome: 'Interior do MA', faixas: ['65100000', '65999999', '65940-000']},
            {estado: 'MG', tipo: 'capital', nome: 'Belo Horizonte', faixas: ['30000000', '34999999', '31540-473']},
            {estado: 'MG', tipo: 'interior', nome: 'Interior de MG', faixas: ['35000000', '39999999', '37800-000']},
            {estado: 'MS', tipo: 'capital', nome: 'Campo Grande', faixas: ['79000000', '79129999', '79104-570']},
            {estado: 'MS', tipo: 'interior', nome: 'Interior do MS', faixas: ['79130000', '79999999', '79400-000']},
            {estado: 'MT', tipo: 'capital', nome: 'Cuiabá', faixas: ['78000000', '78109999', '78048-245']},
            {estado: 'MT', tipo: 'interior', nome: 'Interior do MT', faixas: ['78110000', '78899999', '78175-000']},
            {estado: 'PA', tipo: 'capital', nome: 'Belém', faixas: ['66000000', '67999999', '66820-820']},
            {estado: 'PA', tipo: 'interior', nome: 'Interior do PA', faixas: ['68000000', '68899999', '68371-163']},
            {estado: 'PB', tipo: 'capital', nome: 'João Pessoa', faixas: ['58000000', '58099999', '58028-860']},
            {estado: 'PB', tipo: 'interior', nome: 'Interior da PB', faixas: ['58100000', '58999999', '58805-350']},
            {estado: 'PE', tipo: 'capital', nome: 'Recife', faixas: ['50000000', '54999999', '52031-216']},
            {estado: 'PE', tipo: 'interior', nome: 'Interior do PE', faixas: ['55000000', '56999999', '56909-716']},
            {estado: 'PI', tipo: 'capital', nome: 'Teresina', faixas: ['64000000', '64099999', '64062-080']},
            {estado: 'PI', tipo: 'interior', nome: 'Interior do PI', faixas: ['64100000', '64999999', '64215-360']},
            {estado: 'PR', tipo: 'capital', nome: 'Curitiba', faixas: ['80000000', '83800999', '80510-330']},
            {estado: 'PR', tipo: 'interior', nome: 'Interior do PR', faixas: ['83801000', '87999999', '85840-000']},
            {estado: 'RJ', tipo: 'capital', nome: 'Rio De Janeiro', faixas: ['20000000', '26600999', '23591-450']},
            {estado: 'RJ', tipo: 'interior', nome: 'Interior do RJ', faixas: ['26601000', '28999999', '28035-005']},
            {estado: 'RN', tipo: 'capital', nome: 'Natal', faixas: ['59000000', '59099999', '59123-029']},
            {estado: 'RN', tipo: 'interior', nome: 'Interior do RN', faixas: ['59100000', '59999999', '59612-300']},
            {estado: 'RO', tipo: 'capital', nome: 'Porto Velho', faixas: ['78900000', '78930999', '76801-016']},
            {estado: 'RO', tipo: 'interior', nome: 'Interior de RO', faixas: ['78931000', '78999999', '76890-000']},
            {estado: 'RR', tipo: 'capital', nome: 'Boa Vista', faixas: ['69300000', '69339999', '69310-030']},
            {estado: 'RR', tipo: 'interior', nome: 'Interior de RR', faixas: ['69340000', '69389999', '69373-000']},
            {estado: 'RS', tipo: 'capital', nome: 'Porto Alegre', faixas: ['90000000', '94900999', '91330-730']},
            {estado: 'RS', tipo: 'interior', nome: 'Interior do RS', faixas: ['94901000', '99999999', '94475-770']},
            {estado: 'SC', tipo: 'capital', nome: 'Florianópolis', faixas: ['88000000', '88469999', '88066-410']},
            {estado: 'SC', tipo: 'interior', nome: 'Interior de SC', faixas: ['88470000', '89999999', '88818-286']},
            {estado: 'SE', tipo: 'capital', nome: 'Aracajú', faixas: ['49000000', '49099999', '49027-390']},
            {estado: 'SE', tipo: 'interior', nome: 'Interior de SE', faixas: ['49100000', '49999999', '49704-000']},
            {estado: 'SP', tipo: 'capital', nome: 'São Paulo', faixas: ['01000000', '09999999', '01303-001']},
            {estado: 'SP', tipo: 'interior', nome: 'Interior de SP', faixas: ['11000000', '19999999', '13760-000']},
            {estado: 'TO', tipo: 'capital', nome: 'Palmas', faixas: ['77000000', '77270999', '77064-318']},
            {estado: 'TO', tipo: 'interior', nome: 'Interior do TO', faixas: ['77300000', '77995999', '77423-510']}
          ]
        end
        ranges
      end

      def self.weight_ranges(service_code)
        weights = []
        if service_code == "40215" || service_code == "40290"
          weights = [
            [0.0, 0.3], [0.3, 0.5], [0.5, 0.75], [0.75, 1.0], [1.0, 1.5], [1.5, 2.0], [2.0, 2.5], [2.5, 3.0], [3.0, 3.5],
            [3.5, 4.0], [4.0, 4.5], [4.5, 5.0], [5.0, 6.0], [6.0, 7.0], [7.0, 8.0], [8.0, 9.0], [9.0, 10.0], [10.0, 11.0],
            [11.0, 12.0], [12.0, 13.0], [13.0, 14.0], [14.0, 15.0]
          ]
        else
          weights = [
            [0.0, 0.3], [0.3, 0.5], [0.5, 0.75], [0.75, 1.0], [1.0, 1.5], [1.5, 2.0], [2.0, 2.5], [2.5, 3.0], [3.0, 3.5],
            [3.5, 4.0], [4.0, 4.5], [4.5, 5.0], [5.0, 6.0], [6.0, 7.0], [7.0, 8.0], [8.0, 9.0], [9.0, 10.0], [10.0, 11.0],
            [11.0, 12.0], [12.0, 13.0], [13.0, 14.0], [14.0, 15.0], [15.0, 16.0], [16.0, 17.0], [17.0, 18.0], [18.0, 19.0],
            [19.0, 20.0], [20.0, 21.0], [21.0, 22.0], [22.0, 23.0], [23.0, 24.0], [24.0, 25.0], [25.0, 26.0], [26.0, 27.0],
            [27.0, 28.0], [28.0, 29.0], [29.0, 30.0]
          ]
        end
        weights     
      end

      private

      def cast_to_float!(*attributes)
        attributes.each do |attr|
          value = send(attr).to_s.gsub(".", "").gsub("," ,".")
          instance_variable_set("@#{attr}", value.to_f)
        end
      end

      def cast_to_int!(*attributes)
        attributes.each do |attr|
          instance_variable_set("@#{attr}", send(attr).to_i)
        end
      end

      def cast_to_boolean!(*attributes)
        attributes.each do |attr|
          instance_variable_set("@#{attr}", send(attr) == "S")
        end
      end

    end
  end
end
