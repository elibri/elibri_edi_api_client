# -*- encoding : utf-8 -*-
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

    #zwraca dane jako base64
    def download_pdf
      JSON.parse(session.get("v1/invoices/#{self.id}/get_pdf").body)["blob"]
    end

    def upload_pdf(blob)
      @data = { blob: Base64::encode64(blob) }
      put 'v1/invoices/:id/upload_pdf'
      return self
    end

  end
end
