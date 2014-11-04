# -*- encoding : utf-8 -*-
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

    def self.find_by_order_id(order_id)
      raise InputDataError, "Invalid order_id provided"  unless order_id.kind_of? Integer
      o = new(order_id: order_id)
      o.get "v1/despatch_advices/by_order_id?order_id=#{order_id}"
      o
    end

    def self.create(data)
      unless data[:edi_purchase_order_id]
        raise InputDataError, "Can't create DespatchAdvice without :edi_purchase_order_id provided"
      else
        po = PurchaseOrder.new data[:edi_purchase_order_id]
        po.create_message data
      end
    end

  end
end
