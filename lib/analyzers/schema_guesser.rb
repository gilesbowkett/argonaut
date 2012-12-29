class SchemaGuesser

  def connect
    config = YAML.load_file "mongo.yml"

    @connection = Mongo::Connection.new config["host"], config["port"], :slave_ok => true
    @database = @connection[config["database"]]
    @database.authenticate(config["user"], config["password"])
  end

  attr_accessor :example
  attr_reader :collection

  def collection=(name)
    @collection = @database[name]
    @example = nil # reset, because of memoization in #fields()
  end

  def random_element
    # not under spec because it's really just a Mongo query. translated from:
    # http://stackoverflow.com/questions/2824157/random-record-from-mongodb
    @collection.find.limit(-1).skip(rand(@collection.count - 1)).next
  end

  # a shortcut because it happens a lot in the rake tasks
  def get_schema_from_random_element
    raise "this Mongo collection is empty" if @collection.count == 0
    classify_collection_attributes(random_element)
  end

  def fields
    @example ||= random_element
    return false unless @example
    (@example.keys - ["_id"]).map &:to_sym
  end

  def classify_collection_attributes(instance)
    mongo_translation_schema = MongoTranslationSchema.new
    mongo_translation_schema.classify_attribute_values(instance)
    mongo_translation_schema
  end

  def each &block
    collection.find.each &block
  end
end

