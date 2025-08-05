# frozen_string_literal: true
require "test_helper"
class DeepStructStoreTest < Minitest::Test
  class Foo < ActiveRecord::Base
    include DeepStructStore
    deep_struct_store :api_response
  end

  def setup
    # Create table fresh for each test run
    ActiveRecord::Schema.define do
      create_table :foos, force: true do |t|
        t.json :api_response
      end
    end
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
  end

  def test_nil_for_blank_data
    foo = Foo.create!(api_response: nil)
    assert_nil foo.api_response
  end
end
