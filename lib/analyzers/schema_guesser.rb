class SchemaGuesser

  attr_accessor :example, :json

  # json really represents a collection of *parsed* JSON objects, as would be
  # returned from Mongo or JSON.parse. FIXME: TomDoc.
  def initialize(json = nil)
    @json = json
  end

  # a shortcut because it happens a lot in the rake tasks (100% legacy)
  def get_schema_from_random_element
    classify_collection_attributes(@json.next)
  end

  def fields
    @example ||= @json.next
    return false unless @example
    (@example.keys - ["_id"]).map &:to_sym
  end

  def classify_collection_attributes(instance)
    mongo_translation_schema = MongoTranslationSchema.new
    mongo_translation_schema.classify_attribute_values(instance)
    mongo_translation_schema
  end

end

