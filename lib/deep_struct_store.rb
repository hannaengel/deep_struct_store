# frozen_string_literal: true
require "active_support"
require "active_support/concern"
require "ostruct"

module DeepStructStore
  extend ActiveSupport::Concern

  class_methods do
    def deep_struct_store(*attr_names, **options)
      coder = options.delete(:coder) || JSON

      attr_names.each do |attr_name|
        store attr_name, coder: coder, **options.except(:accessors)

        # Getter
        define_method(attr_name) do
          raw_data = super()
          return nil if raw_data.blank?
          deep_open_struct(raw_data)
        end

        # Setter (allow passing structs or hashes)
        # drawbacks -- only allows full reassignment via OpenStruct Object, not partial updates
        define_method("#{attr_name}=") do |val|
          if val.is_a?(OpenStruct)
            super(deep_struct_to_hash(val))
          else
            super(val)
          end
        end

        # Optional accessor shortcuts
        if options[:accessors]
          options[:accessors].each do |accessor|
            define_method(accessor) do
              public_send(attr_name)&.public_send(accessor)
            end
          end
        end
      end
    end
  end

  private

  # Custom OpenStruct subclass to allow indifferent access
  class IndifferentOpenStruct < OpenStruct
    # now you can call Foo.last.api_response[:key][:value1] or Foo.last.api_response.key.value1 or Foo.last.dig(:key, :value1)
    def [](key)
      public_send(key)
    end

    def dig(*keys)
      keys.inject(self) { |value, key| value&.public_send(key) }
    end
  end

  def deep_open_struct(value)
    case value
    when Hash
      safe_hash = value.each_with_object({}) do |(k, v), h|
        key = k.to_sym rescue k # symbol if possible
        h[key] = deep_open_struct(v)
      end
      IndifferentOpenStruct.new(safe_hash)
    when Array
      value.map { |v| deep_open_struct(v) }
    else
      value
    end
  end

  def deep_struct_to_hash(value)
    case value
    when OpenStruct
      value.to_h.transform_values { |v| deep_struct_to_hash(v) }
    when Array
      value.map { |v| deep_struct_to_hash(v) }
    else
      value
    end
  end
end
