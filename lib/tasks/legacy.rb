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

end

