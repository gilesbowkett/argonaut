require File.expand_path(File.dirname(__FILE__)) + "/boot"

require File.here "/lib/data_types/array"
require File.here "/lib/data_types/array_of_mongo_ids"
require File.here "/lib/data_types/array_of_mongo_objects"
require File.here "/lib/data_types/boolean"
require File.here "/lib/data_types/string"
require File.here "/lib/data_types/fixnum"
require File.here "/lib/data_types/float"
require File.here "/lib/data_types/nil_class"
require File.here "/lib/data_types/optional_timestamp"
require File.here "/lib/data_types/bson_object_id"
require File.here "/lib/data_types/bson_ordered_hash"

require File.here '/lib/analyzers/schema'
require File.here '/lib/analyzers/mongo_analyzer'
require File.here '/lib/analyzers/file_analyzer'

require File.here "/lib/formatters/formatter"
require File.here "/lib/formatters/ascii_formatter"
require File.here "/lib/formatters/migration_formatter"
require File.here "/lib/formatters/translator_model_formatter"

require File.here "/ruby-beautifier/lib/ruby-beautifier/beautifier"

require File.here '/lib/json_collections/random_mongo_objects'
require File.here '/lib/json_collections/parsed_json'
require File.here '/lib/json_collections/json_from_a_file'

require File.here '/lib/tasks/mongo'
require File.here '/lib/tasks/filesystem'

# migrations without Rails, from readme at https://github.com/thuss/standalone-migrations
begin
  require 'tasks/standalone_migrations'
rescue LoadError => e
  puts "gem install standalone_migrations to get db:migrate:* tasks! (Error: #{e})"
end

desc "dummy task for debugging env issues"
task :wtf do
  puts "hello world"
end

