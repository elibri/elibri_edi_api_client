# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  class PreorderForm < Base

    class << self
      attr_accessor :config_secret
    end

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

    def url_for_email(email)
      signature = url_signature self.id, email
      (URI.parse(ElibriEdiApiClient::Base.config_base_url) + url_for("forms/preorder/:id/#{email}/#{signature}")).to_s
    end

    private
    def url_signature(form_id, email)
      @digest ||= OpenSSL::Digest::MD5.new
      data = [form_id, email].join
      OpenSSL::HMAC.hexdigest(@digest, ::ElibriEdiApiClient::PreorderForm.config_secret, data)
    end
  end
end
