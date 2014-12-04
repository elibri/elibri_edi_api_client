# -*- encoding : utf-8 -*-
module ElibriEdiApiClient
  module Factories
    class PreorderForm

      include ActiveModel::Validations

      attr_accessor :seller_id,           # EDI seller's company id
                    :name,                # form name  
                    :intro,               # from intro - html
                    :record_references,   # list of eLibri record references
                    :valid_until

      validates :seller_id, presence: true
      validates :name, presence: true
      validates :record_references, presence: true

      def initialize(attributes={})
        attributes.assert_valid_keys :seller_id, :name, :intro, :valid_until
        attributes.each do |key, value|
          self.send("#{key}=", value.to_s)
        end
        self.record_references = []
      end

      def add_record_reference(record_reference)
        record_references << record_reference
      end

      def to_edi_message
        raise InsufficientData unless valid?

        {}.tap do |res|
          res[:kind] = 'PREORDER_FORM'
          res[:seller_id] = seller_id
          res[:name] = name
          res[:intro] = intro
          res[:record_references] = record_references
          res[:valid_until] = valid_until
        end
      end
    end
  end
end
