class MongoAnalyzer

  def initialize(collection)

    random_from_mongo = RandomMongoObjects.new
    @collection = collection
    random_from_mongo.collection = @collection

    @schema_guesser = SchemaGuesser.new
    @schema_guesser.json = random_from_mongo

  end

  def analyze_repeatedly(iterations)

    instances = []
    iterations.times do
      instances << @schema_guesser.get_schema_from_next_element
    end

    @options = {:schema => MongoTranslationSchema.create_from_many(instances),
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
