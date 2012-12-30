# FIXME: write some specs! (this file was refactored from a rake task)

class FileSystemAnalyzer

  def show_me_partially_analyzed_schemas(filename)
    parsed = JSONFromAFile.load filename

    parsed.each do |schemaless_object|
      ap Schema.classify_collection_attributes(schemaless_object).attributes
    end
  end

  # for some reason the analysis is not recursing FIXME
  def broken_analyze_method_wtf(filename)
    parsed = JSONFromAFile.load filename

    instances = parsed.collect do |parsed_json_object|
      Schema.classify_collection_attributes(parsed_json_object)
    end

    ap Schema.create_from_many(instances).attributes
  end

end

