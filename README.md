# Rastreioz

Esta Gem pertence ao serviço Rastreioz, que permite consultar o serviço de calculo de preços e prazos, rastreamento de encomenda e consulta de endereços diretamente dos Correios, com resultado armazenado em cache de algumas horas para aumentar a velocidade e disponibilidade da consulta.

O Rastreioz fornece os resultados dessa consulta através de uma API autenticada que está sendo disponibilizada
sem custo adicional, porém, é possível que no futuro ocorra a a cobrança de uma taxa anual somente para a manutenção e hospedagem dos serviços. Ainda assim, se esse serviço for útil para você ou seu site, aceitamos sua doação para ajudar a pagar o café :)

A implementação da API utiliza a linguagem Ruby no serviço Lambda da AWS e essa Gem faz a interface com os recursos, além da autenticação por JWT.

VERSÃO BETA: Atenção, essa API e a Gem são utilizadas por uma loja virtual em produção e já recebeu mais de 4.8k requisições desde que foi iniciado a utilização em 19/12/18 até o período de 20/01/19. A utilização em produção, apesar do bom resultado, é por sua conta e risco. O Rastreioz não se responsabiliza por eventuais interrupções do serviço ou mudança da API no período Beta.

## Instalação

Inclua essa linha ao arquivo Gemfile da sua aplicação:

```ruby
gem 'rastreioz'
```

E então execute o comando:

    $ bundle

Ou instale separadamente dessa forma:

    $ gem install rastreioz

## Uso

1) Primeiro você deve criar uma conta para ter acesso a api_key e a api_password gerados automáticamente no cadastro. Obs: Possíveis abusos serão excluídos sem aviso.

    $ curl -H "Content-Type: application/x-www-form-urlencoded" -X POST https://api.rastreioz.com/users/signup -d 'email=usuario@dominio.com.br&full_name=Seu Nome&password=12345678&password_confirmation=12345678'

```
{"message":"Account created successfully","auth_token":"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiZmFkM2MyMzItYzZjNy00MjI2LWI1N2ItNDc2Y2ZlM2JlNzQzIiwiZXhwIjoxNTQ3NTEwODA1fQ.W0ftZ_LX_j14ybNwZ1b1G6LeMQA8C--_JQirXdkXRUU","api_key":"ak_5c5743369a774b78993966d8c2d8a1f5","api_password":"d7f259ac4812bde6dfc67523304a1244"}
```

2) Após receber a api_key e a api_password, você deve guardar com segurança essa informações, pois não podem ser regeradas 
neste momento e a api_password não será exibida novamente.

```ruby
Rastreioz.api_key = "ak_5c5743369a774b78993966d8c2d8a1f5"
Rastreioz.api_password = "d7f259ac4812bde6dfc67523304a1244"
```

3) Após a configuração da gem com a api_key e a api_password recebida, é possível calcular o custo e o prazo da entrega dos serviços sem um contrato com o Correios:

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
Calcular valor do Frete:

```ruby
Rastreioz::Frete.calcular([:pac, :sedex, :sedex_10], {cep_origem: '01154-010', cep_destino: '06351-140', peso: 2, formato: :caixa_pacote, comprimento: 20, altura: 20, largura: 20, diametro: 20, valor_declarado: 115.00})
```

Caso você tenha um contrato com o correio, pode informar o seu código_empresa e a senha. Essas informações não são armazenadas pelo Rastreioz.

```ruby
Rastreioz::Frete.calcular([:e_sedex, :sedex_10, :pac_com_contrato, :sedex_com_contrato_1], {cep_origem: '01154-010', cep_destino: '06351-140', peso: 2, formato: :caixa_pacote, comprimento: 20, altura: 20, largura: 20, diametro: 20, valor_declarado: 115.00, codigo_empresa: 11111111, senha: 11111111})
```
4) A próxima estapa será mostrar o rastreamento dos correios. Ainda em construção.

## Desenvolvimento

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contribuição

Avisos de erros e pull requests são bem vindos nesse repositório https://github.com/base16soft/rastreioz. O projeto destina-se a ser um espaço seguro e acolhedor para colaboração, e espera-se que os colaboradores sigam o código de conduta do [Pacto do Colaborador](http://contributor-covenant.org)

## License

O código fonte dessa gem está disponível sob os termos da [licença MIT](https://opensource.org/licenses/MIT).

## Código de Conduta

Qualquer interação o código base dessa gem, dúvidas, avisos de erros (issues) ou troca de mensagens deve seguir o seguinte [código de conduta](https://github.com/base16soft/rastreioz/blob/master/CODE_OF_CONDUCT.md).
