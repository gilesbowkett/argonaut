class ImplicitJSONSchema

  attr_accessor :attributes
  def initialize(attributes = {})
    @attributes = attributes
  end

  def self.classify_collection_attributes(instance)
    implicit_json_schema = new
    implicit_json_schema.classify_attribute_values(instance)
    implicit_json_schema
  end

  def self.create_from_many(instances)
    return new if instances.blank?

    schema = instances.shift
    instances.inject(schema) do |schema, instance|
      schema.merge(instance)
      schema
    end
  end

  # FIXME: this class often seems like it decorates Hash but should just
  # subclass it. this is definitely one of those times.
  def merge(other_schema)

    # input can be a Hash or a thing which has a Hash
    other_attributes = case other_schema
      when ImplicitJSONSchema
        other_schema.attributes
      when Hash
        other_schema
    end

    other_attributes.each do |attribute, value|
      # if the other schema has a nil for an attribute, then throw that away, because
      # it means the attribute was never classified
      unless value
        other_attributes.delete(attribute)
        next
      end

      # if both schema ascribe different data types to the same attribute? problem
      if @attributes[attribute] && value != @attributes[attribute]
        ap "WARNING: schemas don't match on attribute #{attribute}"
      end
    end

    @attributes.merge!(other_attributes)

  end

  # Internal - generalize data types based on specific data. in most
  # cases you just want the class of a given piece of data, for instance
  # if a Mongo object has the "name" attribute and its value is a String,
  # that's all you're going to need to know in order to generate the
  # migration and the translator model. In other cases you have small
  # transformations to make, for instance you're going to represent a
  # BSON::ObjectId in SQL as a string, so you transform it into a String
  # here. For a nil, you want to just send back a nil, so the code which
  # uses this knows not to draw any conclusions, and likewise if it's a
  # Mongo object, you send it back as-is, so the analyzer can get all
  # recursive on that ass and find out what the schema is for that
  # embedded Mongo object.
  #
  # attributes_and_values - a Hash. usually a Mongo object from Mongomatic
  #
  def classify_attribute_value(attributes_and_values)
    raise "collection might be empty" unless attributes_and_values
    attributes_and_values.each do |attribute, value|
      attribute = "mongo_id" if "_id" == attribute
      value = case value
        when TrueClass, FalseClass
          Boolean
        when Time
          OptionalTimestamp
        when Array
          classify_array(attribute, value)
        when NilClass, BSON::OrderedHash
          value
        else
          value.class
      end
      @attributes[attribute.to_sym] = value
    end
  end
  alias :classify_attribute_values :classify_attribute_value

  def classify_array(name, array)
    if array.collect(&:class).uniq == [BSON::ObjectId]
      ArrayOfMongoIds
    elsif array.collect(&:class).uniq == [BSON::OrderedHash]
      ArrayOfMongoObjects
    elsif array.empty? && name =~ /.+_ids$/
      # wild-ass guess, will obviously change (FIXME), only valid for Mongo use case
      ArrayOfMongoIds
    else
      Array
    end
  end
end

