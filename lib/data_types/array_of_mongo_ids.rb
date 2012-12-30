module Argonaut
  class ArrayOfMongoIds
    def self.to_text_label
      "array of Mongo IDs"
    end

    # if you have this class, you're going to do something a little more complicated at this point.
    # an array of Mongo IDs is typically represented by a join table, since you can't really store
    # arrays in SQL rows.
    def self.to_migration_label(attribute)
      "FIXME :#{attribute}"
    end
  end
end
