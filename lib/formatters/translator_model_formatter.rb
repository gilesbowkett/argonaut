# caveat: this file is half legacy and half vaporware. basically, all this code is extracted from a
# project where, for analytics purposes, a company wanted to convert all its Mongo data to SQL automatically
# and on an ongoing basis. in order to do this, I cooked up a DSL for that translation. it works a lot like
# ActiveRecord, although I regret that design decision. you create MongoTranslator models for the collections
# you want to translate to SQL, and the translation DSL mostly consists of class methods on MongoTranslator.

# anyway, the code in this file can generate simple MongoTranslator models when it encounters simple Mongo
# collections. I'm not throwing it away yet, but I might throw it away later. I haven't open sourced the
# MongoTranslator DSL or the code which makes it work, but I hope to soon.

class TranslatorModelFormatter < Formatter

  def format
    @output ||= ''

    @stuff_to_create.each do |class_name, schema|
      @output += header(class_name)
      @output += column_names(schema)
      @output += from_mongo_collection(class_name)
      @output += translate_literally(schema)
      @output += translates_mongo_ids(schema)
      @output += converts_datetimes(schema)
      @output += footer
    end

    @output
  end

  # FIXME: the pattern here is overwhelmingly methods which are basically just template containers,
  # and the format method strings these template containers together. only a few of these little
  # methods actually do any real logic. so the cleaner organizational model is undoubtedly something
  # like Rails views, where you have a /templates or even /views dir, and this thing just does ERB
  # against external files rather than internal HEREDOCs (which are always a bit ugly).

  def header(translator_name)
    output =<<HEADER
# filename: lib/translators/#{translator_name.to_s.singularize.underscore}.rb
class #{translator_name.to_s.singularize.camelize} < MongoTranslator
HEADER
  end

  def footer
    output =<<FOOTER

end

FOOTER
  end

  # FIXME: practically everything which uses a Schema goes straight into its
  # attributes hash. Law of Demeter. you probably just want MTS to be a Hash subclass or something.
  def column_names(schema)
    output =<<COLUMN_NAMES
  def self.column_names
    #{schema.attributes.keys.sort}
  end

  attr_accessor *column_names
COLUMN_NAMES
    output
  end

  def from_mongo_collection(class_name)
    output =<<FROM_MONGO


  from_mongo_collection :#{class_name.to_s.pluralize.underscore}

FROM_MONGO
  end

  def translate_literally(schema)
    literal_attributes = (schema.attributes.collect do |attribute, value|
      next if :mongo_id == attribute # translator already handles these automatically
      case value.to_s
      when "String", "Boolean", "Fixnum", "Float", "OptionalTimestamp"
        attribute
      end
    end).compact.uniq
    return "" if literal_attributes.empty?
    output =<<TRANSLATE_LITERALLY
  translate_literally #{literal_attributes.collect{|attribute| ":#{attribute}"}.join(", ")}
TRANSLATE_LITERALLY
    output
  end

  def converts_datetimes(schema)
    timestamps = (schema.attributes.collect do |attribute, value|
      case value.to_s
      when "OptionalTimestamp"
        attribute
      end
    end).compact.uniq
    return "" if timestamps.empty?
    output =<<TIMESTAMPS

  converts_utc_to_pacific #{timestamps.collect{|attribute| ":#{attribute}"}.join(", ")}

TIMESTAMPS
  end

  # FIXME: DRY. this is very similar to the above method. there's a pattern emerging, which is
  # a good sign for a chance to clean things up a bit.
  def translates_mongo_ids(schema)
    mongo_ids = (schema.attributes.collect do |attribute, value|
      next if :mongo_id == attribute # already handled automatically by the translator code
      case value.to_s
      when "BSON::ObjectId"
        attribute
      end
    end).compact.uniq
    return "" if mongo_ids.empty?
    output =<<MONGO_IDS

  translates_mongo_ids #{mongo_ids.collect{|attribute| ":#{attribute}"}.join(", ")}

MONGO_IDS
  end
end

