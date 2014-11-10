# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  class ReceiveAdvice < Base

    # Receive Advice is only accessible as linked PurchaseOrder message
    def self.find(data)
      data.symbolize_keys!
      unless data[:order_id] || data[:id]
        fail InputDataError, "Can't find ReceiveAdvice without :id and :order_id provided"
      end

      o = new(data)
      o.get "v1/purchase_orders/:order_id/receive_advices/:id"
      o
    end

    def self.create(data)
      unless data[:order_id]
        fail InputDataError, "Can't create ReceiveAdvice without :order_id provided"
      else
        po = PurchaseOrder.new data[:order_id]
        po.create_message data
      end
    end

  end
end
