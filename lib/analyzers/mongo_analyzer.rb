class MongoAnalyzer

  def initialize(collection)

    @random_mongo_objects = RandomMongoObjects.new
    @collection = collection
    @random_mongo_objects.collection = @collection

    @schema_guesser = SchemaGuesser.new

  end

  def analyze_repeatedly(iterations)

    instances = []
    iterations.times do
      instances << ImplicitJSONSchema.classify_collection_attributes(@random_mongo_objects.next)
    end

    @options = {:schema => ImplicitJSONSchema.create_from_many(instances),
                :class_name => @collection}
  end

  def schema
    @options[:schema]
  end

  def preliminary_translation_to_ruby
    parser = RubyBeautifier.new(TranslatorModelFormatter.new(@options).format)
    parser.parse
    puts parser.processed
  end

  def full_report
    parser = RubyBeautifier.new(TranslatorModelFormatter.new(@options).format)
    parser.parse
    filename = "lib/translators/#{@collection.singularize}.rb"
    File.open(filename, 'w') do |file|
      file.puts parser.processed
    end

    filename = "db/migrate/#{Time.now.utc.strftime '%Y%m%d%H%M%S'}_create_#{@collection}.rb"
    File.open(filename, 'w') do |file|
      file.puts MigrationFormatter.new(@options).format
    end
    puts AsciiFormatter.new(@options).format
  end

end
