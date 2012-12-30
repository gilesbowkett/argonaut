module Argonaut
  # FIXME: DESTROY?
  class JSONFromAFile
    def self.load(filename)
      ParsedJson.new(JSON.parse File.read(filename))
    end
  end

end
