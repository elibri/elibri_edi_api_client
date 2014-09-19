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
          res[:tax_rate] = self.tax_rate.to_s
          res[:net_amount] = self.net_amount.to_s
          res[:tax_amount] = self.tax_amount.to_s
          res[:gross_amount] = (self.net_amount + self.tax_amount).to_s
        end
      end
    end
  end
end
