require 'spec_helper'

describe Formatter do

  context "simple case" do
    before do
      # absurdly simplified business model
      @class_name = "salsas"
      @embedded = BSON::OrderedHash.new
      @embedded["description"] = "jalapeno, mango, red onion, garlic, lime"
      @schema = MongoTranslationSchema.new({
        "name" => String,
        "detail" => @embedded
      })
    end

    describe MigrationFormatter do
      context "figuring out what to create" do

        before do
          @migration_formatter = MigrationFormatter.new(:schema => @schema,
                                                        :class_name => @class_name)
        end

        it "identifies tables to create" do
          @migration_formatter.stuff_to_create.keys.sort.should == ["details", "salsas"]
        end

        it "identifies the attributes of those tables" do
          @migration_formatter.stuff_to_create["salsas"].attributes.should == {
            "name" => String
          }
          @migration_formatter.stuff_to_create["details"].attributes.should == {
            :description => String,
            :salsa_id => Fixnum
          }
        end
      end

      it "creates a migration" do
        @migration_formatter = MigrationFormatter.new(:schema => @schema,
                                                      :class_name => @class_name)
        desired_output =<<DESIRED_OUTPUT
class CreateSalsas < ActiveRecord::Migration
  def self.up
    create_table :salsas do |table|
      table.string :name
    end

    create_table :details do |table|
      table.string :description
      table.integer :salsa_id
    end

  end

  def self.down
    drop_table :salsas

    drop_table :details

  end
end
DESIRED_OUTPUT

        @migration_formatter.format.should == desired_output
      end
    end

    describe AsciiFormatter do
      it "recurses" do
        @ascii = AsciiFormatter.new(:schema => @schema, :class_name => @class_name)
        desired_output =<<DESIRED_OUTPUT
creating MongoTranslator instance Salsa
  name: string
  detail: Mongo object
  creating MongoTranslator instance Detail
    description: string
DESIRED_OUTPUT

        @ascii.format.should == desired_output
      end
    end

    describe TranslatorModelFormatter do

      it "creates a simple translator model" do
        @simple_translator =<<SIMPLE_TRANSLATOR
# filename: lib/translators/salsa.rb
class Salsa < MongoTranslator
  def self.column_names
    ["name"]
  end

  attr_accessor *column_names


  from_mongo_collection :salsas

  translate_literally :name

end

# filename: lib/translators/detail.rb
class Detail < MongoTranslator
  def self.column_names
    [:description, :salsa_id]
  end

  attr_accessor *column_names


  from_mongo_collection :details

  translate_literally :description, :salsa_id

end

SIMPLE_TRANSLATOR
        @translator_formatter = TranslatorModelFormatter.new(:schema => @schema,
                                                             :class_name => 'salsa')
        @translator_formatter.format.should == @simple_translator
      end
    end

  end

  context "more fully-fledged example" do
    before do

      @muppet = BSON::OrderedHash.new
      @muppet["acrobatics_count"] = 1 
      @muppet["rebound_count"] = 0 
      @muppet["accessed_by"] = []
      @muppet["recollected_by"] = []
      @muppet["revived_by"] = []
      @muppet["_id"] = BSON::ObjectId('4dd3b9b0c9423a0d75000004')
      # Mongo doesn't seem to allow you to set up an ordered hash with just the
      # regular Hash syntax. please correct me if I'm wrong on this because it
      # looks like ass. PS: I kind of hate Mongo.

      @salsa_schema = MongoTranslationSchema.new({
        :_keywords => Array,
        :mongo_id => String,
        :active => Boolean,
        :color_ids => ArrayOfMongoIds,
        :created_at => OptionalTimestamp,
        :facebook => nil,
        :flagged_count => Fixnum,
        :price => Float,
        :muppet => @muppet
      })
    end

    it "generates a complex migration" do
      @complex_migration =<<COMPLEX_MIGRATION
raise 'human must adapt migration file because :_keywords attribute confuses stupid robot'
raise 'human must adapt migration file because :color_ids attribute confuses stupid robot'
raise 'human must adapt migration file because :facebook attribute confuses stupid robot'
raise 'human must adapt migration file because :accessed_by attribute confuses stupid robot'
raise 'human must adapt migration file because :recollected_by attribute confuses stupid robot'
raise 'human must adapt migration file because :revived_by attribute confuses stupid robot'
class CreateSalsas < ActiveRecord::Migration
  def self.up
    create_table :salsas do |table|
      table.FIXME :_keywords
      table.boolean :active
      table.FIXME :color_ids
      table.datetime :created_at, :null => true
      table.FIXME :facebook
      table.integer :flagged_count
      table.string :mongo_id
      table.decimal :price, :precision => 6, :scale => 2
    end

    create_table :muppets do |table|
      table.FIXME :accessed_by
      table.integer :acrobatics_count
      table.string :mongo_id # Mongo ID
      table.integer :rebound_count
      table.FIXME :recollected_by
      table.FIXME :revived_by
      table.integer :salsa_id
    end

  end

  def self.down
    drop_table :salsas

    drop_table :muppets

  end
end
COMPLEX_MIGRATION
        @migration_formatter = MigrationFormatter.new(:schema => @salsa_schema,
                                                      :class_name => 'salsa')
        @migration_formatter.format.should == @complex_migration
    end

    it "accomodates arrays of mongo ids in the migrations somehow"

    describe TranslatorModelFormatter do
      before do
        @translator_formatter = TranslatorModelFormatter.new(:schema => @salsa_schema,
                                                             :class_name => 'salsa')
      end

      it "doesn't senselessly make a blank 'translates_mongo_ids' statement" do
        @translator_formatter.translates_mongo_ids(@salsa_schema).should == ""
      end

      it "creates a 'converts_utc_to_pacific' method as needed" do
        created_at = "\n  converts_utc_to_pacific :created_at\n\n"
        @translator_formatter.converts_datetimes(@salsa_schema).should == created_at
      end

      it "doesn't senselessly make a blank 'converts_utc_to_pacific' statement" do
        muppet = @translator_formatter.stuff_to_create["muppets"]
        @translator_formatter.converts_datetimes(muppet).should == ""
      end

      it "generates a pair of complex translator models" do
        @complex_translator =<<COMPLEX_TRANSLATOR
# filename: lib/translators/salsa.rb
class Salsa < MongoTranslator
  def self.column_names
    [:_keywords, :active, :color_ids, :created_at, :facebook, :flagged_count, :mongo_id, :price]
  end

  attr_accessor *column_names


  from_mongo_collection :salsas

  translate_literally :active, :created_at, :flagged_count, :price

  converts_utc_to_pacific :created_at


end

# filename: lib/translators/muppet.rb
class Muppet < MongoTranslator
  def self.column_names
    [:accessed_by, :acrobatics_count, :mongo_id, :rebound_count, :recollected_by, :revived_by, :salsa_id]
  end

  attr_accessor *column_names


  from_mongo_collection :muppets

  translate_literally :acrobatics_count, :rebound_count, :salsa_id

end

COMPLEX_TRANSLATOR
        @translator_formatter.format.should == @complex_translator
      end

    end

  end
end

