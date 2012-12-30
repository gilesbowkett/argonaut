class SchemaGuesser

  attr_accessor :example, :json

  # json really represents a collection of *parsed* JSON objects, as would be
  # returned from Mongo or JSON.parse. FIXME: TomDoc.
  def initialize(json = nil)
    @json = json
  end

end

