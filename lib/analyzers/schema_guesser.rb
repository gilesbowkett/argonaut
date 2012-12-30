class SchemaGuesser

  attr_accessor :example, :json

  # json really represents a collection of *parsed* JSON objects, as would be
  # returned from Mongo or JSON.parse. FIXME: TomDoc.
  def initialize(json = nil)
    @json = json
  end

  # a shortcut because it happens a lot in the rake tasks (100% legacy)
  def get_schema_from_next_element
    classify_collection_attributes(@json.next)
  end

  def classify_collection_attributes(instance)
    implicit_json_schema = ImplicitJSONSchema.new
    implicit_json_schema.classify_attribute_values(instance)
    implicit_json_schema
  end

end

