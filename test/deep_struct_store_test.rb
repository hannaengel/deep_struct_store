# frozen_string_literal: true
require "test_helper"
class DeepStructStoreTest < Minitest::Test
  class Foo < ActiveRecord::Base
    include DeepStructStore
    deep_struct_store :api_response, coder: JSON, accessors: [:baz]
  end

  class Bar < ActiveRecord::Base
    include DeepStructStore
    deep_struct_store :api_response, coder: YAML, accessors: [:baz]
  end

  def setup
    # Create table fresh for each test run
    ActiveRecord::Schema.define do
      create_table :foos, force: true do |t|
        t.json :api_response
      end
       create_table :bars, force: true do |t|
        t.text :api_response
      end
    end
  end

  def test_indifferent_access_with_brackets
    foo = Foo.create!(
      api_response: {
        key: {
          value1: "abc",
          value2: 123
        }
      }
    )

    assert_equal "abc", foo.api_response[:key][:value1]
    assert_equal 123, foo.api_response[:key][:value2]
  end

  def test_indifferent_access_with_method
    foo = Foo.create!(
      api_response: {
        key: {
          value1: "xyz"
        }
      }
    )

    assert_equal "xyz", foo.api_response.key.value1
  end

  def test_indifferent_access_with_dig
    foo = Foo.create!(
      api_response: {
        key: {
          value1: "digged"
        }
      }
    )

    assert_equal "digged", foo.api_response.dig(:key, :value1)
  end

  def test_indifferent_access_with_string_keys
    foo = Foo.create!(
      api_response: {
        "key" => {
          "value1" => "stringy"
        }
      }
    )

    assert_equal "stringy", foo.api_response[:key][:value1]
    assert_equal "stringy", foo.api_response.key.value1
    assert_equal "stringy", foo.api_response.dig("key", "value1")
  end

  def test_array_of_structs_indifferent_access
    foo = Foo.create!(
      api_response: {
        items: [
          { name: "A", value: 1 },
          { name: "B", value: 2 }
        ]
      }
    )

    assert_equal "A", foo.api_response.items[0].name
    assert_equal 2, foo.api_response.items[1].value
  end

  def test_returns_deep_open_struct
    foo = Foo.create!(
      api_response: {
        name: "Widget",
        details: { color: "red", size: "small" }
      }
    )

    assert_equal "Widget", foo.api_response.name
    assert_equal "red", foo.api_response.details.color
    assert_equal "small", foo.api_response.details.size
    assert_nil foo.baz
  end

  def test_returns_deep_open_struct_for_yaml_coder_and_respects_accessors
    bar = Bar.create!(
      api_response: {
        baz: "bizz",
        name: "Widget",
        details: { color: "blue", size: "large" }
      }
    )

    assert_equal "Widget", bar.api_response.name
    assert_equal "blue", bar.api_response.details.color
    assert_equal "large", bar.api_response.details.size
    assert_equal "bizz", bar.baz
  end

  def test_nil_for_blank_data
    foo = Foo.create!(api_response: nil)
    assert_nil foo.api_response
  end

  def test_setter_assigns_value
    foo = Foo.create!(api_response: { name: "Old" })
    foo.api_response = { name: "New", extra: "Value" }
    foo.save!
    foo.reload

    assert_equal "New", foo.api_response.name
    assert_equal "Value", foo.api_response.extra

    foo.api_response.name = "Updated"
    foo.save!
    foo.reload

    assert_equal "Updated", foo.api_response.name
  end
end
