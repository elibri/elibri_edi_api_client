# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  module Factories
    class Order

      include ActiveModel::Validations

      attr_accessor :buyer_number,      #internal order number
                    :buyer_id,          #buyer_id in edi
                    :seller_id,         #seller_id in edi
                    :delivery_id,       #delivery_id - if delivery adress is different, then buyer address
                    :order_date,        #you may leave it blank, it will set to the current time
                    :requested_date,    #when do you expect the shipment
                    :due_date,          #you may leave it blank, it's only important, when you set despatching_mode to multi
                    :despatching_mode,  #one of (single, multi) - 
                    :invoicing_mode,    #one of (with_despatch, after_receive) - should the invoice be created with shipment, or after the customer
                                        #has confirmed, what he or she has received
                    :line_items         #one or many of LineItem


      validates :buyer_number, presence: true
      validates :buyer_id, presence: true
      validates :seller_id, presence: true
      validates :despatching_mode, presence: true, inclusion: { in: %w(single multi digital quarantine) }
      validates :invoicing_mode, presence: true, inclusion: { in: %w(with_despatch after_receive no_invoice digital_clearance) }


      def initialize(attributes={})
        attributes.each do |key, value|
          self.send("#{key}=", value.to_s)
        end
        self.line_items = []
      end

      def add_line_item(item)
        if item.is_a?(Hash)
          self.line_items << LineItem.new(item)
        elsif item.is_a?(LineItem)
          self.line_items << item
        else
          raise ArgumentError, "Hash or ElibriEdiApiClient::Factories::LineItem expected"
        end
      end

      def to_edi_message
        raise InsufficientData unless valid?

        {}.tap do |res|
          res[:kind] = 'ORDER'
          res[:buyer_number] = self.buyer_number
          res[:buyer_id] = self.buyer_id
          res[:seller_id] = self.seller_id
          res[:delivery_id] = self.delivery_id || self.buyer_id
          res[:order_date] = self.order_date || Date.today.to_s
          res[:requested_date] = self.requested_date || Date.tomorrow.to_s
          res[:due_date] = self.due_date || (Date.today + 7.days).to_s
          res[:despatching_mode] = self.despatching_mode
          res[:invoicing_mode] = self.invoicing_mode
          res[:line_items] = self.line_items.map(&:to_hash).each_with_index.map { |line, idx| line[:position] = (idx + 1).to_s; line }
        end
      end
    end
  end
end
