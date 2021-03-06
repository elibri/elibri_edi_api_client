# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  module Factories
    class Invoice

      include ActiveModel::Validations

      attr_accessor :invoice_number,           #numer faktury
                    :document_type,            #rodzaj faktury, 'i': regularna faktura, 'c': faktura korygująca
                    :seller_id,                #numer kartoteki sprzedającego
                    :buyer_id,                 #numer kartoteki kupującego
                    :delivery_detail_id,       #numer kartoteki dla wysyłki
                    :order_id,                 #numer zamówienia
                    :order_buyer_number,       #numer zamówienia w systemie kupującego


                    :invoice_date,             #data wystawienia faktury
                    :sales_date,               #data sprzedaży
                    :delivery_date,            #data dostawy
                    :payment_due_date,         #data płatności

                    :seller_name,              #nazwa sprzedawcy
                    :seller_address,           #adres sprzedawcy
                    :seller_city,              #siedziba sprzedawcy
                    :seller_post_code,         #kod pocztowy sprzedawcy
                    :seller_tax_id,            #nip sprzedawcy

                    :buyer_name,               #nazwa kupującego
                    :buyer_address,            #adres kupującego
                    :buyer_city,               #siedziba kupującego
                    :buyer_post_code,          #kod pocztowy kupującego
                    :buyer_tax_id,             #nip kupującego

                    :delivery_detail_name,     #miejsce odbioru towaru
                    :delivery_detail_address,  #adres adresu odbioru
                    :delivery_detail_city,     #miasto adresu odbioru
                    :delivery_detail_post_code,#kod pocztowy adresu dostawy

                    :pdf,                      #pdf z fakturą - base64

                    :items,               #one or many of InvoiceItem
                    :summary_lines


      validates :buyer_id, presence: true
      validates :seller_id, presence: true
      validates :delivery_detail_id, presence: true
      validates :invoice_number, presence: true

      validates :invoice_date, :sales_date, :payment_due_date, presence: true
      validates :seller_name, :seller_address, :seller_city, :seller_post_code, :seller_tax_id, presence: true
      validates :buyer_name, :buyer_address, :buyer_city, :buyer_post_code, :buyer_tax_id, presence: true
      validates :delivery_detail_name, :delivery_detail_address, :delivery_detail_city, :delivery_detail_post_code, presence: true

      validates :document_type, presence: true, inclusion: { in: %w(i c) }

      def initialize(attributes={})
        attributes.each do |key, value|
          self.send("#{key}=", value.to_s)
        end
        self.items = []
        self.summary_lines = []
      end

      def add_line_item(item)
        if item.is_a?(Hash)
          self.items << InvoiceItem.new(item)
        elsif item.is_a?(InvoiceItem)
          self.items << item
        else
          raise ArgumentError, "Hash or ElibriEdiApiClient::Factories::InvoiceItem expected"
        end
      end

      def add_summary_line(line)
        if line.is_a?(Hash)
          self.summary_lines << InvoiceSummaryLine.new(line)
        elsif line.is_a?(InvoiceSummaryLine)
          self.summary_lines << line
        else
          raise ArgumentError, "Hash or ElibriEdiApiClient::Factories::InvoiceSummaryLine expected"
        end
      end

      def net_amount
        summary_lines.map(&:net_amount).sum
      end

      def tax_amount
        summary_lines.map(&:tax_amount).sum
      end

      def to_edi_message
        raise InsufficientData unless valid?

        {}.tap do |res|
          res[:kind] = 'INVOICE'
          res[:invoice_number] = self.invoice_number
          res[:document_type] = self.document_type
          res[:seller_id] = self.seller_id
          res[:buyer_id] = self.buyer_id
          res[:delivery_detail_id] = self.delivery_detail_id
          res[:order_id] = self.order_id
          res[:order_buyer_number] = self.order_buyer_number if self.order_buyer_number.present?

          res[:invoice_date] = self.invoice_date
          res[:sales_date] = self.sales_date
          res[:delivery_date] = self.delivery_date
          res[:payment_due_date] = self.payment_due_date

          res[:seller_name] = self.seller_name
          res[:seller_address] = seller_address
          res[:seller_city] = self.seller_city
          res[:seller_post_code] = self.seller_post_code
          res[:seller_tax_id] = seller_tax_id

          res[:buyer_name] = self.buyer_name
          res[:buyer_address] = self.buyer_address
          res[:buyer_city] = self.buyer_city
          res[:buyer_post_code] = self.buyer_post_code
          res[:buyer_tax_id] = self.buyer_tax_id

          res[:delivery_detail_name] = self.delivery_detail_name
          res[:delivery_detail_address] = self.delivery_detail_address
          res[:delivery_detail_city] = self.delivery_detail_city
          res[:delivery_detail_post_code] = self.delivery_detail_post_code

          res[:pdf] = self.pdf if self.pdf.present?

          nonzero_quantity_lines = items.reject {|i| i.quantity.to_i == 0}
          res[:items] = nonzero_quantity_lines.map(&:to_hash).each_with_index.map { |line, idx| line[:position] = (idx + 1).to_s; line }

          res[:summary] = {
            :total_lines => nonzero_quantity_lines.count.to_s,
            :net_amount => self.net_amount.to_s,
            :tax_amount => self.tax_amount.to_s,
            :gross_amount => (self.net_amount + self.tax_amount).to_s,
            :items_count => self.items.size.to_s,
            :tax_rate_summaries => self.summary_lines.map(&:to_hash)
          }
        end
      end
    end
  end
end
