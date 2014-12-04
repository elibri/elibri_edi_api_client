# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  class PreorderForm < Base

    def self.create(data)
      o = new(data)
      o.post 'v1/preorder_forms'
      o
    end

    def self.find(id_or_data)
      o = new(id_or_data)
      o.get "v1/preorder_forms/:id"
      o
    end
  end
end
