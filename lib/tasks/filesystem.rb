namespace :argonaut do

  namespace :filesystem do

    desc 'Setup for filesystem Rake tasks'
    # dammit, this is, in other words, #initialize() FIXME
    task :filesystem_setup do
      @schema_guesser = SchemaGuesser.new
    end

    # this code is terrible. I apologize to anyone who is reading it. also
    # for some reason the analysis is not recursing FIXME
    desc "analyze the JSON in a file"
    task :analyze, [:filename] => [:filesystem_setup] do |task, args|
      parsed = JSONFromAFile.load args.filename
      @schema_guesser.json = parsed

      # wow, this code is so awesome FIXME
      instances = parsed.collect do |parsed_json_object|
        @schema_guesser.get_schema_from_next_element
      end

      ap MongoTranslationSchema.create_from_many(instances).attributes
    end

    desc "this shows you partially-analyzed schemas"
    task :wtf, [:filename] => [:filesystem_setup] do |task, args|

      parsed = JSONFromAFile.load args.filename
      @schema_guesser.json = parsed

      parsed.each do |schemaless_object|
        ap @schema_guesser.classify_collection_attributes(schemaless_object).attributes
      end

    end

  end
end

