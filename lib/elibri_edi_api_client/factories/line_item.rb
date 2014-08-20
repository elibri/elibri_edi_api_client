module ElibriEdiApiClient
  module Factories
    class LineItem

      include ActiveModel::Validations


      attr_accessor :quantity,   
                    :net_price,   #netto_unit_price
                    :tax_percent,
                    :ean,
                    :buyer_code,  #may be blank
                    :description

      def initialize(attributes={})
        attributes.each do |key, value|
          self.send("#{key}=", value)
        end
      end

      def to_hash
        {}.tap do |res|
          res[:quantity] = self.quantity
          res[:net_price] = self.net_price if self.net_price.present?
          res[:tax_percent] = self.tax_percent if self.tax_percent.present?
          res[:ean] = self.ean 
          res[:buyer_code] = self.buyer_code if self.buyer_code.present?
          res[:description] = self.description if self.description.present?
        end
      end
    end
  end
end
