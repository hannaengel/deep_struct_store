# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "minitest/autorun"
require "active_record"
require "deep_struct_store"

# Connect to in-memory SQLite DB
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Silence schema output
ActiveRecord::Schema.verbose = false
