class NilClass
  def to_text_label
    "null (unknown)"
  end

  def to_migration_label(attribute)
    "FIXME :#{attribute}" # if you have this class, you do not have enough information to auto-generate the migration.
  end
end