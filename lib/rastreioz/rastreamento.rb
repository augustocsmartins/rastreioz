module Rastreioz
  class Rastreamento

    attr_accessor :bairro, :cep, :localidade, :logradouro, :uf

    URL = "https://api.rastreioz.com/cep"

    def initialize(options = {})
    end

  end
end
