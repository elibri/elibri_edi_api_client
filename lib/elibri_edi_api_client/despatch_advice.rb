module ElibriEdiApiClient
  class DespatchAdvice < Base

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

    def self.find_by_buyer_number(buyer_number)
      o = new(buyer_number: buyer_number)
      o.get "v1/despatch_advices/by_buyer_number?number=#{CGI::escape buyer_number}"
      o
    end

    def self.find_by_order_id(order_id)
      raise InputDataError, "Invalid order_id provided"  unless order_id.kind_of? Integer
      o = new(order_id: order_id)
      o.get "v1/despatch_advices/by_order_id?order_id=#{order_id}"
      o
    end

    def self.create(data)
      unless data[:order_id]
        raise InputDataError, "Can't create DespatchAdvice without :order_id provided"
      else
        po = PurchaseOrder.new data[:order_id]
        po.create_message data
      end
    end

    def set_buyer_number(buyer_number)
      self.replace_data(buyer_number: buyer_number, id: id)
      post "v1/despatch_advices/:id/set_buyer_number"
    end
  end
end
