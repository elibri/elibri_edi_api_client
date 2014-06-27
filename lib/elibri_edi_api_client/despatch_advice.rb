module ElibriEdiApiClient
  class DespatchAdvice < Base
    # TODO: instrukcja użyci

    #TODO: podczas tworzenia obiektu podać gdzieś wersję, żeby nie 
    #dawać na sztywno w wywołaniach
    def self.find(id_or_data)
      o = new(id_or_data)
      o.get "v1/despatch_advices/:id"
      o
    end

  end
end
