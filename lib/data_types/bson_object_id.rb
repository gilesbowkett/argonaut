class BSON::ObjectId

  def self.to_text_label
    "Mongo ID"
  end

  def self.to_migration_label(attribute)
    "string :#{attribute} # Mongo ID"
  end
end
