# frozen_string_literal: true

require "active_support"
require "active_support/concern"
require "ostruct"
require_relative "deep_struct_store/version"

module DeepStructStore
  extend ActiveSupport::Concern

  class_methods do
    def deep_struct_store(*attr_names, **options)
      coder = options.delete(:coder) || JSON

      attr_names.each do |attr_name|
        store attr_name, coder: coder, **options

        define_method(attr_name) do
          raw_data = super() # Original Rails store getter
          return nil if raw_data.blank?
          deep_open_struct(raw_data.deep_symbolize_keys)
        end
      end
    end
  end

  private

  def deep_open_struct(hash)
    OpenStruct.new(
      hash.transform_values do |v|
        v.is_a?(Hash) ? deep_open_struct(v) : v
      end
    )
  end

  class Error < StandardError; end
end

# Example usage:
# class Interview < ApplicationRecord
#   include DeepStructStore
#   deep_struct_store :event, :invitee, :event_type
# end
