namespace :argonaut do
  namespace :filesystem do

    desc "analyze the JSON in a file"
    task :analyze, [:filename] do |task, args|
      @file_analyzer = Argonaut::FileAnalyzer.new(args[:filename])
      @file_analyzer.broken_analyze_method_wtf
    end

    desc "this shows you partially-analyzed schemas"
    task :wtf, [:filename] do |task, args|
      @file_analyzer = Argonaut::FileAnalyzer.new(args[:filename])
      @file_analyzer.schemas
    end

  end
end

