# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  module Factories
    class InvoiceItem

      include ActiveModel::Validations

      attr_accessor :quantity,   
                    :net_price,   
                    :net_amount,
                    :tax_rate,
                    :tax_amount,
                    :ean,
                    :buyer_code,  #may be blank
                    :description, 
                    :reference_number #PKWiU

      validates_numericality_of :net_price, greater_than: 0
      validates :description, presence: true

      def initialize(attributes={})
        attributes.each do |key, value|
          self.send("#{key}=", value.to_s)
        end
      end

      def to_hash
        {}.tap do |res|
          res[:quantity] = self.quantity
          res[:net_price] = self.net_price
          res[:net_amount] = self.net_amount
          res[:tax_rate] = self.tax_rate
          res[:tax_amount] = self.tax_amount
          res[:ean] = self.ean 
          res[:buyer_code] = self.buyer_code if self.buyer_code.present?
          res[:description] = self.description
          res[:reference_number] = self.reference_number if self.reference_number.present?
        end
      end
    end
  end
end
