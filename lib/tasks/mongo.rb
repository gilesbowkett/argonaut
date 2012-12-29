namespace :argonaut do
  namespace :mongo do

    desc 'Setup for Mongo analysis Rake tasks'
    task :mongo_setup do
      @mongo_analyzer = MongoAnalyzer.new(ENV['collection'])
    end

    desc "Thorough analysis, from any number of elements"
    task :thorough_analysis => :mongo_setup do
      @mongo_analyzer.analyze_repeatedly(ENV['iterations'].to_i)
    end

    desc "show analysis"
    task :describe => :thorough_analysis do
      ap @mongo_analyzer.schema.attributes
    end

    desc 'readable translator model from thorough analysis'
    task :readable_translator_model_from_thorough_analysis => :thorough_analysis do
      @mongo_analyzer.preliminary_translation_to_ruby
    end

    desc 'generate migration and model files, and print description to console'
    task :generate => :thorough_analysis do
      @mongo_analyzer.full_report
    end

  end
end

