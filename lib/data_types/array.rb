class Array
  def self.to_text_label
    "array"
  end

  # if you have this class, you do not have enough information to auto-generate the migration.
  # this was a problem when the system worked based on analyzing one randomly-selected element
  # of a Mongo collection, because there would often be empty Arrays; however, if you get this
  # with a thorough analysis (e.g., the :thorough_analysis rake task), then it means the Array
  # contains neither Mongo IDs nor objects. the ArrayOfMongoIds and ArrayOfMongoObjects both
  # have "FIXME" for their migration label, but I'm planning to change that when I create the
  # code to handle those types. this class should remain FIXME forever here, because if you're
  # not getting an ArrayOfMongoIds or an ArrayOfMongoObjects, you should almost certainly either
  # be writing custom code for the attribute, or not migrating it at all.
  def self.to_migration_label(attribute)
    "FIXME :#{attribute}"
  end
end

