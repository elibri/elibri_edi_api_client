# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  module Factories
    class InvoiceSummaryLine

      include ActiveModel::Validations

      attr_accessor :tax_rate,   #stawka podatku
                    :net_amount, #suma netto
                    :tax_amount  #kwota VAT

      def initialize(attributes={})
        attributes.each do |key, value|
          self.send("#{key}=", value)
        end
      end

      def to_hash
        {}.tap do |res|
          res[:tax_rate] = self.tax_rate
          res[:net_amount] = self.net_amount
          res[:tax_amount] = self.tax_amount
          res[:gross_amount] = self.net_amount + self.tax_amount
        end
      end
    end
  end
end
