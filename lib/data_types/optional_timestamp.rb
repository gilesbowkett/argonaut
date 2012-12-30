module Argonaut
  class OptionalTimestamp
    def self.to_text_label
      "timestamp"
    end

    def self.to_migration_label(attribute)
      "datetime :#{attribute}, :null => true"
    end
  end
end
