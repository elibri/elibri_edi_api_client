module ElibriEdiApiClient
  module Factories
    class InvoiceItem

      include ActiveModel::Validations

      attr_accessor :quantity,   
                    :net_price,   
                    :net_amount,
                    :tax_percent,
                    :tax_amount,
                    :ean,
                    :buyer_code,  #may be blank
                    :description, 
                    :reference_number #PKWiU

      def initialize(attributes={})
        attributes.each do |key, value|
          self.send("#{key}=", value)
        end
      end

      def to_hash
        {}.tap do |res|
          res[:quantity] = self.quantity
          res[:net_price] = self.net_price
          res[:net_amount] = self.net_amount
          res[:tax_percent] = self.tax_percent
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
