# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  class ReceiveAdvice < Base

    def self.find(id_or_data)
      o = new(id_or_data)
      o.get "v1/receive_advices/:id"
      o
    end

    def self.create(data)
      unless data[:order_id]
        raise InputDataError, "Can't create ReceiveAdvice without :order_id provided"
      else
        po = PurchaseOrder.new data[:order_id]
        po.create_message data
      end
    end

  end
end
