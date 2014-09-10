# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  module Factories
    class ReceiveAdvice

      include ActiveModel::Validations

      attr_accessor :order_id,                 #numer zamówienia
                    :despatch_advice_id,       #numer awiza dostawy
                    :buyer_number,             #numer u kupującego
                    :line_items

      validates :order_id, presence: true
      validates :despatch_advice_id, presence: true
      validates :buyer_number, presence: true

      def initialize(attributes={})
        attributes.each do |key, value|
          self.send("#{key}=", value)
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
          res[:kind] = 'RECADV'
          res[:order_id] = self.order_id
          res[:buyer_number] = self.buyer_number
          res[:despatch_advice_id] = self.despatch_advice_id
          res[:line_items] = self.line_items.map(&:to_hash).each_with_index.map { |line, idx| line[:position] = idx + 1; line }
        end
      end
    end
  end
end
