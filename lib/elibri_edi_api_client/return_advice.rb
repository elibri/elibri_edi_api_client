# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  class ReturnAdvice < Base

    def self.find(id_or_data)
      o = new(id_or_data)
      o.get "v1/return_advices/:id"
      o
    end

    def self.create(data)
      o = new(data)
      o.post 'v1/return_advices'
      o
    end
  end
end
