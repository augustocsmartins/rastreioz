# Rastreioz

Esta Gem pertence ao serviço Rastreioz, que permite consultar o serviço de calculo de preços e prazos, rastreamento de encomenda e consulta de endereços diretamente dos Correios, com resultado armazenado em uma tabela para aumentar a velocidade e disponibilidade da consulta.

## Instalação

Inclua essa linha ao arquivo Gemfile da sua aplicação:

```ruby
gem 'rastreioz'
```

E então execute o comando:

    $ bundle

Ou instale separadamente dessa forma:

    $ gem install rastreioz

No Rails, você deve executar o comando:

    $ rake rastreioz:install:migrations

## Uso

No primeiro uso, você deve preencher a tabela com os valores das faixas de cep, utilizando seu cep de origem e informações de acesso fornecidas pelo correios, através do comando:

```ruby
Rastreioz::App::CalculaFrete.calcular([:pac_com_contrato, :sedex_com_contrato_1], {cep_origem: "CEP_DE_ORIGEM", comprimento: 20, altura: 20, largura: 20, codigo_empresa: CODIGO_DA_EMPRESA, senha: SENHA_CORREIOS})
```

Calcular valor do Frete:

```ruby
Rastreioz::App::Frete.lista_frete([:pac_com_contrato, :sedex_com_contrato_1], {cep_origem: '01154-010', cep_destino: '06351-140', peso: 2, formato: :caixa_pacote, comprimento: 20, altura: 20, largura: 20, diametro: 20, valor_declarado: 115.00})
```

Serviços disponíveis:

```ruby
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
  "4162"  => { :type => :sedex_com_contrato_6,        :name => "SEDEX",          :description => "SEDEX com contrato"                },
  "81019" => { :type => :e_sedex,                     :name => "e-SEDEX",        :description => "e-SEDEX, com contrato"             },
  "81027" => { :type => :e_sedex_prioritario,         :name => "e-SEDEX",        :description => "e-SEDEX Prioritário, com contrato" },
  "81035" => { :type => :e_sedex_express,             :name => "e-SEDEX",        :description => "e-SEDEX Express, com contrato"     },
  "81868" => { :type => :e_sedex_grupo_1,             :name => "e-SEDEX",        :description => "(Grupo 1) e-SEDEX, com contrato"   },
  "81833" => { :type => :e_sedex_grupo_2,             :name => "e-SEDEX",        :description => "(Grupo 2) e-SEDEX, com contrato"   },
  "81850" => { :type => :e_sedex_grupo_3,             :name => "e-SEDEX",        :description => "(Grupo 3) e-SEDEX, com contrato"   }
}
```

## Desenvolvimento

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contribuição

Avisos de erros e pull requests são bem vindos nesse repositório https://github.com/base16soft/rastreioz. O projeto destina-se a ser um espaço seguro e acolhedor para colaboração, e espera-se que os colaboradores sigam o código de conduta do [Pacto do Colaborador](http://contributor-covenant.org)

## License

O código fonte dessa gem está disponível sob os termos da [licença MIT](https://opensource.org/licenses/MIT).

## Código de Conduta

Qualquer interação o código base dessa gem, dúvidas, avisos de erros (issues) ou troca de mensagens deve seguir o seguinte [código de conduta](https://github.com/base16soft/rastreioz/blob/master/CODE_OF_CONDUCT.md).
