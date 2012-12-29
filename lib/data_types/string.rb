class String
  def self.to_text_label
    "string"
  end

  def self.to_migration_label(attribute)
    "string :#{attribute}"
  end
end
