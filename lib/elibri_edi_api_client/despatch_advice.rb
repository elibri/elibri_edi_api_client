# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  class DespatchAdvice < Base

    # Despatch Advice is only accessible as linked PurchaseOrder message
    def self.find(data)
      data.symbolize_keys!
      unless data[:order_id] || data[:id]
        fail InputDataError, "Can't find DespatchAdvice without :id and :order_id provided"
      end

      o = new(data)
      o.get "v1/purchase_orders/:order_id/despatch_advices/:id"
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
      unless data[:order_id]
        raise InputDataError, "Can't create DespatchAdvice without :order_id provided"
      else
        po = PurchaseOrder.new data[:order_id]
        po.create_message data
      end
    end

  end
end
