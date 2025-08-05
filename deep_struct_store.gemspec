# frozen_string_literal: true

require_relative "lib/deep_struct_store/version"

Gem::Specification.new do |spec|
  spec.name = "deep_struct_store"
  spec.version = DeepStructStore::VERSION
  spec.authors = ["Hanna Engel"]
  spec.email = ["hengel@alumni.berklee.edu"]

  spec.summary = "allow method chaining calls on stores."
  spec.description = "This gem allows for method chaining calls on stores, making it easier to work with deeply nested data structures like large api payloads that you might be storing in ActiveRecord."
  spec.homepage = "https://github.com/hannaengel/deep_struct_store.git"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hannaengel/deep_struct_store"
  spec.metadata["changelog_uri"] = "https://github.com/hannaengel/deep_struct_store/blob/master/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 6.0"
  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "ostruct"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "sqlite3", ">= 2.1"
end
