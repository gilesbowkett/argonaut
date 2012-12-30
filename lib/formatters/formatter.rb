class Formatter
  attr_accessor :stuff_to_create

  # Public - well mostly public, .new() is public at least. set it up with init options
  # hash, and identify stuff the formatter will need to create.
  #
  # options - an ActiveRecord-y options hash
  # options[:schema] - an ImplicitJSONSchema for the JSON object type
  # options[:class_name] - a String naming the JSON object type
  # options[:indents] - spaces to indent the output
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
          # FIXME: first, @class_name drives the ID-attribute-naming process (which could
          # be its own method, for readability). so you can't recurse, or at least not
          # elegantly, because @class_name remains the same no matter how many times you call
          # it, and this method is not passing itself into the "recursion." second, the magic
          # number 1 is here because if you just set it to Fixnum, the #classify_collection_attributes
          # method will reset that to Class. this code is crazier than the worst stretches of Rails.
          # it's using a Formatter instance variable to track the name of the class which contains
          # the class it is mapping. that means using a Formatter to track the implicit belongs_to
          # class name of Schema instances contained within Schema instances.
          #
          # Rails does a lot wrong in ActiveRecord, but one thing it gets brilliantly right is
          # belongs_to and has_one. I could have avoided this whole thing if belongs_to and has_many
          # were operators at a language level instead of class methods at a framework level. These
          # words should be operators in any object-oriented language.
          #
          # JavaScript uses a fundamental language construct to express belongs_to, namely 
          # prototypal inheritance, but it has no matching, equivalent has_one, and you can
          # understand how confused and inelegant most JavaScript code is when you consider that
          # people use the word "inheritance" to refer to JavaScript's prototypes feature.
          #
          # "Inheritance" refers to a patriarchal economic principle which emerged in the agriculutral
          # era. "Inheritance" passes properties to subclasses because the metaphor centers around
          # a hierarchical view of "parent" and "children" classes. This is not the only way to
          # structure a society, so you should not be surprised to discover that it is not the only
          # way to structure a programming language either.
          #
          # The best way to understand JavaScript's object model is to read one of the first botany
          # papers of Western science, by the scientist, novelist, poet, philosopher, and playwright
          # Goethe:
          #
          # http://en.wikipedia.org/wiki/Metamorphosis_of_Plants
          #
          # In it, Goethe observes how plants transform as they first bud, blossom, and bloom. Where
          # reproduction is digital in animals, it is analog in plants. When an animal gives birth, you
          # increment an integer; when plants reproduce, you add to a float.
          #
          # In class-oriented languages, instantiating a class is digital. But in JavaScript, the
          # difference between an object and its "parent" is more fluid. Every object contains a
          # reference to its prototype; every object knows what object it belongs_to.
          #
          # Anyway, long story short, if I had a clearer way to articulate that, I wouldn't have
          # built this crazy thing. What I need to do instead is have a Schema object with an
          # optional belongs_to, and tear this half-assed quasi-recursive bullshit out of this
          # file, and get it into Schema somehow.
          #
          # By the way, if you read all this, you should totally buy my book:
          #
          # http://railsoopbook.com/
        key = attribute.to_s.pluralize
        @stuff_to_create[key] = ImplicitJSONSchema.classify_collection_attributes(value)
        @schema.attributes.delete attribute

      end
    end
  end

end

