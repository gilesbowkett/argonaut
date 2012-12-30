class AsciiFormatter < Formatter

  def header(class_name)
    template =<<-TEMPLATE
#{' ' * @indents}creating MongoTranslator instance #{class_name.to_s.singularize.camelize}
    TEMPLATE
    ERB.new(template).result(binding)
  end

  def line(attribute, value)
    template =<<-TEMPLATE
#{' ' * @indents}  #{attribute}: #{value.to_text_label}
    TEMPLATE
    ERB.new(template).result(binding)
  end

  # Internal - this overrides the superclass version to do nothing. I wrote this formatter before the
  # other ones, and implemented this same functionality inside format.
  def identify_stuff_to_create
  end


  def format
    output = header(@class_name)
    @schema.attributes.each do |attribute, value|
      output += line(attribute, value)

      if value.class == BSON::OrderedHash # Mongo object
        options = {:schema => Schema.classify_collection_attributes(value),
                   :class_name => attribute,
                   :indents => @indents + 2}
        recurse_baby_recurse = AsciiFormatter.new(options)
        output += recurse_baby_recurse.format
      end

    end
    output
  end
end

