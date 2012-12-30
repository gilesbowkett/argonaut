class Formatter
  attr_accessor :stuff_to_create

  # Public - well mostly public, .new() is public at least. set it up with init options
  # hash, and identify stuff the formatter will need to create.
  #
  # options - an ActiveRecord-y options hash
  #
  # Formatter.new(:schema => @listing_schema, :class_name => 'listing')
  # # => returns a Formatter
  def initialize(options = {})
    @schema = options[:schema]
    @class_name = options[:class_name]
    @indents = options[:indents] || 0
    identify_stuff_to_create
  end

  # FIXME: this next method should probably be in the schema object, not here

  # Internal - figure out what things you're going to need to make. The AsciiFormatter doesn't
  # need to create anything, but both the MigrationFormatter and the TranslatorModelFormatter
  # do. This is basically handling nested Mongo objects. It sets a Hash on the Formatter
  # instance which knows what classes the Formatter will need to format -- namely the main
  # class it's addressing, and any association classes -- as well as the schemas for those
  # classes.
  def identify_stuff_to_create
    @stuff_to_create = {@class_name => @schema}
    @schema.attributes.each do |attribute, value|
      if [BSON::OrderedHash, Hash].include?(value.class)
        value["#{@class_name.to_s.singularize}_id"] = 1
          # FIXME: first, tying it directly to the @class_name means you can't recurse,
          # or at least not elegantly. second, the magic number 1 is here because if
          # you just set it to Fixnum, #classify_collection_attributes() will reset that
          # to Class.
        key = attribute.to_s.pluralize
        @stuff_to_create[key] = ImplicitJSONSchema.classify_collection_attributes(value)
        @schema.attributes.delete attribute
      end
    end
  end

end


