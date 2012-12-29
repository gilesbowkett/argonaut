class Float
  def self.to_text_label
    "float"
  end

  def self.to_migration_label(attribute)
    "decimal :#{attribute}, :precision => 6, :scale => 2"
  end
end
