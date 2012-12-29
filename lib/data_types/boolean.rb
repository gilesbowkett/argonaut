class Boolean
  def self.to_text_label
    "boolean"
  end

  def self.to_migration_label(attribute)
    "boolean :#{attribute}"
  end
end
