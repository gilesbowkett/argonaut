namespace :argonaut do

  namespace :filesystem do

    desc "analyze the JSON in a file"
    task :analyze, [:filename] do |task, args|
      parsed = JSONFromAFile.load args.filename
      ap parsed
    end

  end
end
