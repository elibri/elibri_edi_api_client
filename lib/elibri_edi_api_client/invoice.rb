module ElibriEdiApiClient
  class Invoice < Base

    def self.create(data)
      o = new(data)
      o.post 'v1/invoices'
      o
    end

    def self.find(id_or_data)
      i = new(id_or_data)
      i.get "v1/invoices/:id"
      i
    end

  end
end
