# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  class Company < Base

    def_attributes :name, :short_name, :vat_id, :buyer, :seller, :elibri_publisher_id, :street,
                   :city, :zip_code, :phone1, :phone2, :website, :email,
                   :invoicing_mode, :despatching_mode, :code_name, :default_delivery,
                   :cooperates_with, :publishers_in_distribution

    def self.find(id)
      c = new(id)
      c.get "v1/companies/:id"
      c
    end

    def buyer?
      buyer
    end

    def seller?
      seller
    end

    def default_delivery?
      default_delivery
    end

  end
end
