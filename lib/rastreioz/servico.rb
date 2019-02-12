# encoding: UTF-8

module Rastreioz
  class Servico

    AVAILABLE_SERVICES = {
       "4510" => { :type => :pac,                         :name => "PAC",            :description => "PAC sem contrato"                  },
      "41068" => { :type => :pac_com_contrato,            :name => "PAC",            :description => "PAC com contrato"                  },
       "4669" => { :type => :pac_com_contrato_2,          :name => "PAC",            :description => "PAC com contrato"                  },
      "41300" => { :type => :pac_gf,                      :name => "PAC GF",         :description => "PAC para grandes formatos"         },
       "4014" => { :type => :sedex,                       :name => "SEDEX",          :description => "SEDEX sem contrato"                },
      "40045" => { :type => :sedex_a_cobrar,              :name => "SEDEX a Cobrar", :description => "SEDEX a Cobrar, sem contrato"      },
      "40126" => { :type => :sedex_a_cobrar_com_contrato, :name => "SEDEX a Cobrar", :description => "SEDEX a Cobrar, com contrato"      },
      "40215" => { :type => :sedex_10,                    :name => "SEDEX 10",       :description => "SEDEX 10, sem contrato"            },
      "40290" => { :type => :sedex_hoje,                  :name => "SEDEX Hoje",     :description => "SEDEX Hoje, sem contrato"          },
      "40096" => { :type => :sedex_com_contrato_1,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "40436" => { :type => :sedex_com_contrato_2,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "40444" => { :type => :sedex_com_contrato_3,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "40568" => { :type => :sedex_com_contrato_4,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
      "40606" => { :type => :sedex_com_contrato_5,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
       "4162" => { :type => :sedex_com_contrato_6,        :name => "SEDEX",          :description => "SEDEX com contrato"                }
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

    def parse(element)

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

    def sedex_10_hoje(service_code)

      if ($_GET["codigo_servico"] == "40215" || $_GET["codigo_servico"] == "40290") {
        $FAIXAS_CEPS = array(
            array('estado' => 'AC', 'tipo' => 'capital', 'nome' => 'Rio Branco', 'faixas' => array('69900-000', '69923-999', '69911-776')),
            array('estado' => 'AL', 'tipo' => 'capital', 'nome' => 'Maceió', 'faixas' => array('57000-000', '57099-999', '57035-830')),
            array('estado' => 'AM', 'tipo' => 'capital', 'nome' => 'Manaus', 'faixas' => array('69000-000', '69099-999', '69083-350')),
            array('estado' => 'AP', 'tipo' => 'capital', 'nome' => 'Macapá', 'faixas' => array('68900-000', '68911-999', '68909-167')),
            array('estado' => 'BA', 'tipo' => 'capital', 'nome' => 'Salvador', 'faixas' => array('40000-000', '42599-999', '40335-505')),
            array('estado' => 'CE', 'tipo' => 'capital', 'nome' => 'Fortaleza', 'faixas' => array('60000-000', '61599-999', '60744-280')),
            array('estado' => 'DF', 'tipo' => 'capital', 'nome' => 'Brasília', 'faixas' => array('70000-000', '72799-999 ', '71900-500')),
            array('estado' => 'DF', 'tipo' => 'capital', 'nome' => 'Brasília', 'faixas' => array('73000-000', '73699-999', '73090-135')),
            array('estado' => 'ES', 'tipo' => 'capital', 'nome' => 'Vitória', 'faixas' => array('29000-000', '29099-999', '29060-017')),
            array('estado' => 'GO', 'tipo' => 'capital', 'nome' => 'Goiânia', 'faixas' => array('74000-000', '74899-999', '74343-610')),
            array('estado' => 'MA', 'tipo' => 'capital', 'nome' => 'São Luiz', 'faixas' => array('65000-000', '65109-999', '65072-405')),
            array('estado' => 'MG', 'tipo' => 'capital', 'nome' => 'Belo Horizonte', 'faixas' => array('30000-000', '31999-999', '31540-473')),
            array('estado' => 'MS', 'tipo' => 'capital', 'nome' => 'Campo Grande', 'faixas' => array('79000-000', '79124-999', '79104-570')),
            array('estado' => 'MT', 'tipo' => 'capital', 'nome' => 'Cuiabá', 'faixas' => array('78000-000', '78099-999', '78048-245')),
            array('estado' => 'PA', 'tipo' => 'capital', 'nome' => 'Belém', 'faixas' => array('66000-000', '66999-999', '66820-820')),
            array('estado' => 'PB', 'tipo' => 'capital', 'nome' => 'João Pessoa', 'faixas' => array('58000-000', '58099-999', '58028-860')),
            array('estado' => 'PE', 'tipo' => 'capital', 'nome' => 'Recife', 'faixas' => array('50000-000', '52999-999', '52031-216')),
            array('estado' => 'PI', 'tipo' => 'capital', 'nome' => 'Teresina', 'faixas' => array('64000-000', '64099-999', '64062-080')),
            array('estado' => 'PR', 'tipo' => 'capital', 'nome' => 'Curitiba', 'faixas' => array('80000-000', '82999-999', '80510-330')),
            array('estado' => 'RJ', 'tipo' => 'capital', 'nome' => 'Rio De Janeiro', 'faixas' => array('20000-000', '23799-999', '23591-450')),
            array('estado' => 'RJ', 'tipo' => 'interior', 'nome' => 'Interior do RJ', 'faixas' => array('23800-000', '28999-999', '28035-005')),
            array('estado' => 'RN', 'tipo' => 'capital', 'nome' => 'Natal', 'faixas' => array('59000-000', '59139-999', '59123-029')),
            array('estado' => 'RN', 'tipo' => 'interior', 'nome' => 'Interior do RN', 'faixas' => array('59140-000', '59999-999', '59612-300')),
            array('estado' => 'RO', 'tipo' => 'capital', 'nome' => 'Porto Velho', 'faixas' => array('76800-000', '76834-999', '76801-016')),
            array('estado' => 'RR', 'tipo' => 'capital', 'nome' => 'Boa Vista', 'faixas' => array('69300-000', '69339-999', '69310-030')),
            array('estado' => 'RS', 'tipo' => 'capital', 'nome' => 'Porto Alegre', 'faixas' => array('90000-000', '91999-999', '91330-730')),
            array('estado' => 'RS', 'tipo' => 'interior', 'nome' => 'Interior do RS', 'faixas' => array('92000-000', '99999-999', '94475-770')),
            array('estado' => 'SC', 'tipo' => 'capital', 'nome' => 'Florianópolis', 'faixas' => array('88000-000', '88099-999', '88066-410')),
            array('estado' => 'SC', 'tipo' => 'interior', 'nome' => 'Interior de SC', 'faixas' => array('88100-000', '89999-999', '88818-286')),
            array('estado' => 'SE', 'tipo' => 'capital', 'nome' => 'Aracajú', 'faixas' => array('49000-000', '49098-999', '49027-390')),
            array('estado' => 'SP', 'tipo' => 'capital', 'nome' => 'São Paulo', 'faixas' => array('01000-000', '09999-999', '01303-001')),
            array('estado' => 'TO', 'tipo' => 'capital', 'nome' => 'Palmas', 'faixas' => array('77000-000', '77249-999', '77064-318')),
        );      
    end

    def zipcode_range
      $FAIXAS_CEPS = array(
        array('estado' => 'AC', 'tipo' => 'capital', 'nome' => 'Rio Branco', 'faixas' => array('69900-000', '69923-999', '69911-776')),
        array('estado' => 'AC', 'tipo' => 'interior', 'nome' => 'Interior do AC', 'faixas' => array('69924-000', '69999-999', '69970-000')),
        array('estado' => 'AL', 'tipo' => 'capital', 'nome' => 'Maceió', 'faixas' => array('57000-000', '57099-999', '57035-830')),
        array('estado' => 'AL', 'tipo' => 'interior', 'nome' => 'Interior do AL', 'faixas' => array('57100-000', '57999-999', '57602-640')),
        array('estado' => 'AM', 'tipo' => 'capital', 'nome' => 'Manaus', 'faixas' => array('69000-000', '69099-999', '69083-350')),
        array('estado' => 'AM', 'tipo' => 'interior', 'nome' => 'Interior do AM', 'faixas' => array('69100-000', '69299-999', '69280-000')),
        array('estado' => 'AM', 'tipo' => 'interior', 'nome' => 'Interior do AM', 'faixas' => array('69400-000', '69899-999', '69280-000')),
        array('estado' => 'AM', 'tipo' => 'interior', 'nome' => 'Interior do AM', 'faixas' => array('69800-000', '69800-000', '69800-000')),
        array('estado' => 'AP', 'tipo' => 'capital', 'nome' => 'Macapá', 'faixas' => array('68900-000', '68911-999', '68909-167')),
        array('estado' => 'AP', 'tipo' => 'interior', 'nome' => 'Interior do AP', 'faixas' => array('68912-000', '68999-999', '68920-000')),
        array('estado' => 'BA', 'tipo' => 'capital', 'nome' => 'Salvador', 'faixas' => array('40000-000', '42599-999', '40335-505')),
        array('estado' => 'BA', 'tipo' => 'interior', 'nome' => 'Interior da BA', 'faixas' => array('42600-000', '48999-999', '44935-000')),
        array('estado' => 'CE', 'tipo' => 'capital', 'nome' => 'Fortaleza', 'faixas' => array('60000-000', '61599-999', '60744-280')),
        array('estado' => 'CE', 'tipo' => 'interior', 'nome' => 'Interior do CE', 'faixas' => array('61600-000', '63999-999', '62748-000')),
        array('estado' => 'DF', 'tipo' => 'capital', 'nome' => 'Brasília', 'faixas' => array('70000-000', '72799-999 ', '71900-500')),
        array('estado' => 'DF', 'tipo' => 'capital', 'nome' => 'Brasília', 'faixas' => array('73000-000', '73699-999', '73090-135')),
        array('estado' => 'ES', 'tipo' => 'capital', 'nome' => 'Vitória', 'faixas' => array('29000-000', '29099-999', '29060-017')),
        array('estado' => 'ES', 'tipo' => 'interior', 'nome' => 'Interior do ES', 'faixas' => array('29100-000', '29999-999', '29860-000')),
        array('estado' => 'GO', 'tipo' => 'capital', 'nome' => 'Goiânia', 'faixas' => array('74000-000', '74899-999', '74343-610')),
        array('estado' => 'GO', 'tipo' => 'interior', 'nome' => 'Interior de GO', 'faixas' => array('72800-000', '72999-999', '76330-000')),
        array('estado' => 'GO', 'tipo' => 'interior', 'nome' => 'Interior de GO', 'faixas' => array('73700-000', '73999-999', '76330-000')),
        array('estado' => 'GO', 'tipo' => 'interior', 'nome' => 'Interior de GO', 'faixas' => array('74900-000', '76799-999', '76330-000')),
        array('estado' => 'MA', 'tipo' => 'capital', 'nome' => 'São Luiz', 'faixas' => array('65000-000', '65109-999', '65072-405')),
        array('estado' => 'MA', 'tipo' => 'interior', 'nome' => 'Interior do MA', 'faixas' => array('65110-000', '65999-999', '65940-000')),
        array('estado' => 'MG', 'tipo' => 'capital', 'nome' => 'Belo Horizonte', 'faixas' => array('30000-000', '31999-999', '31540-473')),
        array('estado' => 'MG', 'tipo' => 'interior', 'nome' => 'Interior de MG', 'faixas' => array('32000-000', '39999-999', '37800-000')),
        array('estado' => 'MS', 'tipo' => 'capital', 'nome' => 'Campo Grande', 'faixas' => array('79000-000', '79124-999', '79104-570')),
        array('estado' => 'MS', 'tipo' => 'interior', 'nome' => 'Interior do MS', 'faixas' => array('79125-000', '79999-999', '79400-000')),
        array('estado' => 'MT', 'tipo' => 'capital', 'nome' => 'Cuiabá', 'faixas' => array('78000-000', '78099-999', '78048-245')),
        array('estado' => 'MT', 'tipo' => 'interior', 'nome' => 'Interior do MT', 'faixas' => array('78100-000', '78899-999', '78175-000')),
        array('estado' => 'PA', 'tipo' => 'capital', 'nome' => 'Belém', 'faixas' => array('66000-000', '66999-999', '66820-820')),
        array('estado' => 'PA', 'tipo' => 'interior', 'nome' => 'Interior do PA', 'faixas' => array('67000-000', '68899-999', '68371-163')),
        array('estado' => 'PB', 'tipo' => 'capital', 'nome' => 'João Pessoa', 'faixas' => array('58000-000', '58099-999', '58028-860')),
        array('estado' => 'PB', 'tipo' => 'interior', 'nome' => 'Interior da PB', 'faixas' => array('58100-000', '58999-999', '58805-350')),
        array('estado' => 'PE', 'tipo' => 'capital', 'nome' => 'Recife', 'faixas' => array('50000-000', '52999-999', '52031-216')),
        array('estado' => 'PE', 'tipo' => 'interior', 'nome' => 'Interior do PE', 'faixas' => array('53000-000', '56999-999', '56909-716')),
        array('estado' => 'PI', 'tipo' => 'capital', 'nome' => 'Teresina', 'faixas' => array('64000-000', '64099-999', '64062-080')),
        array('estado' => 'PI', 'tipo' => 'interior', 'nome' => 'Interior do PI', 'faixas' => array('64100-000', '64999-999', '64215-360')),
        array('estado' => 'PR', 'tipo' => 'capital', 'nome' => 'Curitiba', 'faixas' => array('80000-000', '82999-999', '80510-330')),
        array('estado' => 'PR', 'tipo' => 'interior', 'nome' => 'Interior do PR', 'faixas' => array('83000-000', '87999-999', '85840-000')),
        array('estado' => 'RJ', 'tipo' => 'capital', 'nome' => 'Rio De Janeiro', 'faixas' => array('20000-000', '23799-999', '23591-450')),
        array('estado' => 'RJ', 'tipo' => 'interior', 'nome' => 'Interior do RJ', 'faixas' => array('23800-000', '28999-999', '28035-005')),
        array('estado' => 'RN', 'tipo' => 'capital', 'nome' => 'Natal', 'faixas' => array('59000-000', '59139-999', '59123-029')),
        array('estado' => 'RN', 'tipo' => 'interior', 'nome' => 'Interior do RN', 'faixas' => array('59140-000', '59999-999', '59612-300')),
        array('estado' => 'RO', 'tipo' => 'capital', 'nome' => 'Porto Velho', 'faixas' => array('76800-000', '76834-999', '76801-016')),
        array('estado' => 'RO', 'tipo' => 'interior', 'nome' => 'Interior de RO', 'faixas' => array('76835-000', '76999-999', '76890-000')),
        array('estado' => 'RR', 'tipo' => 'capital', 'nome' => 'Boa Vista', 'faixas' => array('69300-000', '69339-999', '69310-030')),
        array('estado' => 'RR', 'tipo' => 'interior', 'nome' => 'Interior de RR', 'faixas' => array('69340-000', '69399-999', '69373-000')),
        array('estado' => 'RS', 'tipo' => 'capital', 'nome' => 'Porto Alegre', 'faixas' => array('90000-000', '91999-999', '91330-730')),
        array('estado' => 'RS', 'tipo' => 'interior', 'nome' => 'Interior do RS', 'faixas' => array('92000-000', '99999-999', '94475-770')),
        array('estado' => 'SC', 'tipo' => 'capital', 'nome' => 'Florianópolis', 'faixas' => array('88000-000', '88099-999', '88066-410')),
        array('estado' => 'SC', 'tipo' => 'interior', 'nome' => 'Interior de SC', 'faixas' => array('88100-000', '89999-999', '88818-286')),
        array('estado' => 'SE', 'tipo' => 'capital', 'nome' => 'Aracajú', 'faixas' => array('49000-000', '49098-999', '49027-390')),
        array('estado' => 'SE', 'tipo' => 'interior', 'nome' => 'Interior de SE', 'faixas' => array('49099-000', '49999-999', '49704-000')),
        array('estado' => 'SP', 'tipo' => 'capital', 'nome' => 'São Paulo', 'faixas' => array('01000-000', '09999-999', '01303-001')),
        array('estado' => 'SP', 'tipo' => 'interior', 'nome' => 'Interior de SP', 'faixas' => array('10000-000', '19999-999', '13760-000')),
        array('estado' => 'TO', 'tipo' => 'capital', 'nome' => 'Palmas', 'faixas' => array('77000-000', '77249-999', '77064-318')),
        array('estado' => 'TO', 'tipo' => 'interior', 'nome' => 'Interior do TO', 'faixas' => array('77250-000', '77999-999', '77423-510')),
      );      
    end

    def weight_range(service_code)

      if ($_GET["codigo_servico"] == "81019" || $_GET["codigo_servico"] == "40215" || $_GET["codigo_servico"] == "40290") {
        var FAIXAS_PESO = [
          [0.0, 0.3], [0.3, 0.5], [0.5, 0.75], [0.75, 1.0], [1.0, 1.5], [1.5, 2.0], [2.0, 2.5], [2.5, 3.0], [3.0, 3.5],
          [3.5, 4.0], [4.0, 4.5], [4.5, 5.0], [5.0, 6.0], [6.0, 7.0], [7.0, 8.0], [8.0, 9.0], [9.0, 10.0], [10.0, 11.0],
          [11.0, 12.0], [12.0, 13.0], [13.0, 14.0], [14.0, 15.0]
        ];
      } else {
        var FAIXAS_PESO = [
          [0.0, 0.3], [0.3, 0.5], [0.5, 0.75], [0.75, 1.0], [1.0, 1.5], [1.5, 2.0], [2.0, 2.5], [2.5, 3.0], [3.0, 3.5],
          [3.5, 4.0], [4.0, 4.5], [4.5, 5.0], [5.0, 6.0], [6.0, 7.0], [7.0, 8.0], [8.0, 9.0], [9.0, 10.0], [10.0, 11.0],
          [11.0, 12.0], [12.0, 13.0], [13.0, 14.0], [14.0, 15.0], [15.0, 16.0], [16.0, 17.0], [17.0, 18.0], [18.0, 19.0],
          [19.0, 20.0], [20.0, 21.0], [21.0, 22.0], [22.0, 23.0], [23.0, 24.0], [24.0, 25.0], [25.0, 26.0], [26.0, 27.0],
          [27.0, 28.0], [28.0, 29.0], [29.0, 30.0]
          ];
        }
        
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
