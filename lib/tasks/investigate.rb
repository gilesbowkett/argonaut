namespace :mongo do

  desc 'Setup for Mongo analysis Rake tasks'
  task :analysis_setup do
    @collection = ENV['collection']
    @schema_guesser = SchemaGuesser.new
    @schema_guesser.collection = @collection
  end

  desc "Thorough analysis, from any number of elements"
  task :thorough_analysis => :analysis_setup do
    iterations = ENV['iterations']

    instances = []
    iterations.to_i.times do
      instances << @schema_guesser.get_schema_from_random_element
    end

    @options = {:schema => MongoTranslationSchema.create_from_many(instances),
                :class_name => @collection}
  end

  desc "show analysis"
  task :describe => :thorough_analysis do
    ap @options[:schema]
  end


  desc 'readable translator model from thorough analysis'
  task :readable_translator_model_from_thorough_analysis => :thorough_analysis do
    parser = RubyBeautifier.new(TranslatorModelFormatter.new(@options).format)
    parser.parse
    puts parser.processed
  end

  desc 'generate migration and model files, and print description to console'
  task :generate => :thorough_analysis do
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

  # FIXME: everything below here is legacy, and likely to disappear.

  # oldest, legacy-est version
  desc 'Describe existing Mongo collections'
  task :investigate => :analysis_setup do

    fields = @schema_guesser.fields
    if fields
      puts @collection + ": " + @schema_guesser.collection.count.to_s + " records"
      ap fields

      puts "random element from " + @collection
      ap @schema_guesser.random_element

      puts
    end
  end

  desc "Basic analysis, from random element"
  task :basic_random_analysis => :analysis_setup do
    @random_element = @schema_guesser.random_element
    @options = {:schema => @schema_guesser.get_schema_from_random_element,
                :class_name => @collection}
  end

  desc 'Map Mongo collection fields to value types'
  task :describe_collection_attributes => :basic_random_analysis do
    puts AsciiFormatter.new(@options).format
  end

  desc 'generate migration from random Mongo element'
  task :generate_migration_from_random_element => :basic_random_analysis do
    puts MigrationFormatter.new(@options).format
  end

  desc 'generate translator model from random Mongo element'
  task :generate_translator_model_from_random_element => :basic_random_analysis do
    puts TranslatorModelFormatter.new(@options).format
  end

  desc 'generate translator model and migration'
  task :generate_model_and_migration => [:describe_collection_attributes,
                                         :generate_translator_model_from_random_element,
                                         :generate_migration_from_random_element]

end

