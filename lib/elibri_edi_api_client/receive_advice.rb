module ElibriEdiApiClient
  class ReceiveAdvice < Base

    def self.find(id_or_data)
      o = new(id_or_data)
      o.get "v1/receive_advices/:id"
      o
    end

    def self.create(data)
      unless data[:edi_purchase_order_id]
        raise InputDataError.new status: nil, result: "Can't create ReceiveAdvice without :edi_purchase_order_id provided", url: nil
      else
        po = PurchaseOrder.new data[:edi_purchase_order_id]
        po.create_message data
      end
    end

  end
end
