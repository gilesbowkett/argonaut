class Fixnum
  def self.to_text_label
    "integer"
  end

  def self.to_migration_label(attribute)
    "integer :#{attribute}"
  end
end
