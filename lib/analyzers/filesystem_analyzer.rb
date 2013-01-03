# FIXME: write some specs! (this file was refactored from a rake task)

module Argonaut
  class FileSystemAnalyzer < Struct.new(:filename)
    # FIXME: maybe just FileAnalyzer? less pretentious, shorter, more accurate,
    # and allows me to attr_accessor :filename. it is an arg in literally every method, after all.

    def initialize(filename)
      @filename = filename
    end

    def partially_analyzed_schemas
      JSONFromAFile.load(@filename).collect do |schemaless_object|
        Schema.extract_from_json(schemaless_object)
      end
    end

    def show_me_partially_analyzed_schemas
      partially_analyzed_schemas.each do |schema|
        ap schema.attributes
      end
    end

    # for some reason the analysis is not recursing FIXME
    # it's supposed to merge/summarize all individual schemas >.<
    def broken_analyze_method_wtf
      parsed = JSONFromAFile.load(@filename)

      instances = parsed.collect do |parsed_json_object|
        Schema.extract_from_json(parsed_json_object)
      end

      ap Schema.create_from_many(instances).attributes
    end

  end
end

