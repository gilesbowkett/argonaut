# FIXME: write some specs! (this file was refactored from a rake task)

class FileSystemAnalyzer

  def initialize
    @schema_guesser = SchemaGuesser.new
  end

  def show_me_partially_analyzed_schemas(filename)
    parsed = JSONFromAFile.load filename

    parsed.each do |schemaless_object|
      ap ImplicitJSONSchema.classify_collection_attributes(schemaless_object).attributes
    end
  end

  # for some reason the analysis is not recursing FIXME
  def broken_analyze_method_wtf(filename)
    parsed = JSONFromAFile.load filename

    instances = parsed.collect do |parsed_json_object|
      ImplicitJSONSchema.classify_collection_attributes(parsed_json_object)
    end

    ap ImplicitJSONSchema.create_from_many(instances).attributes
  end

end

