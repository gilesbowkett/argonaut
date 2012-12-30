# gems and File.here (setup stuff)
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.require :default

class File
  def self.here(string)
    expand_path(dirname(__FILE__)) + string
  end
end

require 'active_support/all'

require File.here "/../lib/data_types/array"
require File.here "/../lib/data_types/array_of_mongo_ids"
require File.here "/../lib/data_types/array_of_mongo_objects"
require File.here "/../lib/data_types/boolean"
require File.here "/../lib/data_types/string"
require File.here "/../lib/data_types/fixnum"
require File.here "/../lib/data_types/float"
require File.here "/../lib/data_types/nil_class"
require File.here "/../lib/data_types/optional_timestamp"
require File.here "/../lib/data_types/bson_object_id"
require File.here "/../lib/data_types/bson_ordered_hash"

require File.here "/../lib/analyzers/implicit_json_schema"

require File.here "/../lib/json_collections/random_mongo_objects"
require File.here "/../lib/json_collections/parsed_json"
require File.here "/../lib/json_collections/json_from_a_file"

require File.here "/../lib/formatters/formatter"
require File.here "/../lib/formatters/ascii_formatter"
require File.here "/../lib/formatters/migration_formatter"
require File.here "/../lib/formatters/translator_model_formatter"

