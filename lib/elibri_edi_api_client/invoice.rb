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

    # zwraca dane jako base64
    # aktualizuje także własny hash @data o dane i nazwę pliku pdf
    # Jeśli faktura nie ma pdf to zostanie rzucony wyjątek ElibriEdiApiClient::NotFoundError
    def download_pdf
      cached_data = data
      get "v1/invoices/:id/get_pdf"
      pdf_data = data[:blob]
      pdf_filename = data[:file_name]
      replace_data cached_data.merge(pdf: pdf_data, pdf_filename: pdf_filename)
      pdf_data
    end

    def upload_pdf(blob, file_name='invoice.pdf')
      @data = { blob: Base64::encode64(blob), file_name: file_name }
      put 'v1/invoices/:id/upload_pdf'
      self
    end

  end
end
