module ElibriEdiApiClient
  class DespatchAdvice < Base
    # TODO: instrukcja użycia

    #TODO: podczas tworzenia obiektu podać gdzieś wersję, żeby nie 
    #dawać na sztywno w wywołaniach
    def self.find(id_or_data)
      o = new(id_or_data)
      o.get "v1/despatch_advices/:id"
      o
    end

    def self.find_by_seller_number(seller_number)
      o = new(seller_number: seller_number)
      o.get "v1/despatch_advices/by_seller_number?number=#{CGI::escape seller_number}"
      o
    end

    def self.create(data)
      unless data[:edi_purchase_order_id]
        raise InputDataError.new  status: nil, result: "Can't create DespatchAdvice without :edi_purchase_order_id provided", url: nil
      else
        po = PurchaseOrder.new data[:edi_purchase_order_id]
        po.create_message data
      end
    end

  end
end
