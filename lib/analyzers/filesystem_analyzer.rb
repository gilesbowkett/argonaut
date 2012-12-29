# FIXME: write some specs! (this file was refactored from a rake task)

class FileSystemAnalyzer

  def initialize
    @schema_guesser = SchemaGuesser.new
  end

  def show_me_partially_analyzed_schemas(filename)
    parsed = JSONFromAFile.load filename
    @schema_guesser.json = parsed

    parsed.each do |schemaless_object|
      ap @schema_guesser.classify_collection_attributes(schemaless_object).attributes
    end
  end

  # this code is terrible. I apologize to anyone who is reading it. also
  # for some reason the analysis is not recursing FIXME
  def broken_analyze_method_wtf(filename)
    parsed = JSONFromAFile.load filename
    @schema_guesser.json = parsed

    # wow, this code is so awesome FIXME
    instances = parsed.collect do |parsed_json_object|
      @schema_guesser.get_schema_from_next_element
    end

    ap MongoTranslationSchema.create_from_many(instances).attributes
  end

end

