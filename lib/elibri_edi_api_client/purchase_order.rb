# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  class PurchaseOrder < Base
    ##
    # Używać w następujący sposób:
    # # przygotować hash z danymi zgodnie ze specyfikacją API
    # data = { ... }
    # order = ElibriEdiApiClient::PurchaseOrder.create(data)
    # order.read #pobiera (aktualizuje) dane z EDI
    #
    # order = ElibriEdiApiClient::PurchaseOrder.find(7) #pobiera dane zamówienia o podanym id
    # 

    #TODO: podczas tworzenia obiektu podać gdzieś wersję, żeby nie 
    #dawać na sztywno w wywołaniach
    def self.create(data)
      o = new(data)
      o.post 'v1/purchase_orders'
      o
    end

    def self.find(id_or_data)
      o = new(id_or_data)
      o.get "v1/purchase_orders/:id"
      o
    end

    def create_message(data)
      klass = klass_from_kind(data[:kind])
      o = klass.new(data)
      url = self.url_for 'v1/purchase_orders/:id/messages'
      o.post url
    end

    def set_seller_number(seller_number)
      self.replace_data(seller_number: seller_number, id: id)
      post "v1/purchase_orders/:id/set_seller_number"
    end

    def self.find_by_seller_number(seller_number)
      o = new(seller_number: seller_number)
      o.post "v1/purchase_orders/find_by_seller_number"
      o
    end

  end
end
