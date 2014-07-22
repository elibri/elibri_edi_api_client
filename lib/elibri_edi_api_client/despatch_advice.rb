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

    def self.create(data)
      unless data[:edi_purchase_order_id]
        fail InputDataError.new "Can't create DespatchAdvice without :edi_purchase_order_id provided"
      else
        po = PurchaseOrder.new data[:edi_purchase_order_id]
        po.create_message data
      end
    end

  end
end
