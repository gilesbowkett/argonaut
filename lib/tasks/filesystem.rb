namespace :argonaut do
  namespace :filesystem do

    desc 'Setup for filesystem Rake tasks'
    task :filesystem_setup do
      @filesystem_analyzer = Argonaut::FileSystemAnalyzer.new
    end

    desc "analyze the JSON in a file"
    task :analyze, [:filename] => [:filesystem_setup] do |task, args|
      @filesystem_analyzer.broken_analyze_method_wtf(args.filename)
    end

    desc "this shows you partially-analyzed schemas"
    task :wtf, [:filename] => [:filesystem_setup] do |task, args|
      @filesystem_analyzer.show_me_partially_analyzed_schemas(args.filename)
    end

  end
end

