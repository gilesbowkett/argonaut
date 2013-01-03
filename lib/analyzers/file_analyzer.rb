# FIXME: write some specs! (this file was refactored from a rake task)

module Argonaut
  class FileAnalyzer < Struct.new(:filename)

    def initialize(filename)
      @filename = filename
    end

    def schemas
      JSONFromAFile.load(@filename).collect do |schemaless_object|
        Schema.extract_from_json(schemaless_object)
      end
    end

    def show_me_schemas
      schemas.each do |schema|
        ap schema.attributes
      end
    end

    # for some reason the analysis is not recursing FIXME
    # it's supposed to merge/summarize all individual schemas >.<
    def broken_analyze_method_wtf
      ap Schema.create_from_many(schemas).attributes
    end

  end
end

