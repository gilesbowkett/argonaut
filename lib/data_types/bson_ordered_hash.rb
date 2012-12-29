class BSON::OrderedHash

  # this is an instance method, not a class method, which breaks the pattern. it does this because
  # when you have a Mongo object, you actually want to recurse inside it to analyze it, rather than
  # simply identifying it as a Mongo object and calling it a day. you need to get its schema in the
  # process of getting its containing object's schema.
  def to_text_label
    "Mongo object"
  end
end
