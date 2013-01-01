require 'spec_helper'

describe Schema do

  before do
    @schema = Schema.new
  end

  it "classifies Mongo ID fields" do
    @schema.classify_attribute_value("_id" => BSON::ObjectId('4ed937da7a4f9f200e000037'))
    @schema.attributes.should == {:mongo_id => BSON::ObjectId}
  end
  it "classifies Mongo ID arrays when the array contains Mongo IDs" do
    array_of_ids = {"muppet_fan_user_ids"=> [ BSON::ObjectId('4dc66475d5a52c5756000001'),
                                              BSON::ObjectId('4e52f2fddde03222760006d7') ]}
    @schema.classify_attribute_value(array_of_ids)
    @schema.attributes.should == {:muppet_fan_user_ids => ArrayOfMongoIds}
  end
  it "isn't fooled by arrays with varied classes in them" do
    mixed_array = {"muppet_fan_user_ids"=> [ BSON::ObjectId('4dc66475d5a52c5756000001'),
                                            7 ]}
    @schema.classify_attribute_value(mixed_array)
    @schema.attributes.should == {:muppet_fan_user_ids => Array}
  end
  it "classifies Mongo ID arrays when the array's empty and named *_ids" do
    # FIXME: this is useful for Mongo but not for any other source of JSON
    @schema.classify_attribute_value("muppet_ids" => [])
    @schema.attributes.should == {:muppet_ids => ArrayOfMongoIds}
  end

  context "with Mongo objects" do
    before do
      @foobar = BSON::OrderedHash.new
      @foobar["foo"] = "bar"
    end

    it "classifies arrays of Mongo objects" do
      @schema.classify_attribute_value("fraggles" => [@foobar])
      @schema.attributes.should == {:fraggles => ArrayOfMongoObjects}
    end

    it "preserves Mongo objects for later recursive analysis" do
      @schema.classify_attribute_value("dark_crystal" => @foobar)
      @schema.attributes.should == {:dark_crystal => @foobar}
    end
  end

  it "classifies optional timestamps" do
    @schema.classify_attribute_value("created_at" => Time.now)
    @schema.attributes.should == {:created_at => OptionalTimestamp}
  end

  it "classifies falses as booleans" do
    @schema.classify_attribute_value("private" => false)
    @schema.attributes.should == {:private => Boolean}
  end

  it "classifies trues as booleans" do
    @schema.classify_attribute_value("private" => true)
    @schema.attributes.should == {:private => Boolean}
  end

  it "classifies strings" do
    @schema.classify_attribute_value("name" => "Goblin King")
    @schema.attributes.should == {:name => String}
  end

  it "classifies integers" do
    @schema.classify_attribute_value("number_of_hats" => 5)
    @schema.attributes.should == {:number_of_hats => Fixnum}
  end

  it "classifies floats" do
    @schema.classify_attribute_value("price" => 70.0)
    @schema.attributes.should == {:price => Float}
  end

  it "skips nulls" do
    @schema.classify_attribute_value("number_of_hats" => nil)
    @schema.attributes.should == {:number_of_hats => nil}
  end

  it "turns a Mongo hash into its attributes hash" do
    @dj_category = { "_id" => BSON::ObjectId('4ed937da7a4f9f200e000037'),
                     "muppet_ids" => [], 
                     "muppet_fan_user_ids"=>
                        [ BSON::ObjectId('4dc66475d5a52c5756000001'),
                          BSON::ObjectId('4e52f2fddde03222760006d7') ],
                     "created_at" => Time.now,
                     "name" => "Goblin King",
                     "private" => true,
                     "slug" => "dj",
                     "updated_at" => Time.now
                   }

    @attributes = {
      :mongo_id => BSON::ObjectId,
      :muppet_ids => ArrayOfMongoIds,
      :muppet_fan_user_ids => ArrayOfMongoIds,
      :created_at => OptionalTimestamp,
      :name => String,
      :private => Boolean,
      :slug => String,
      :updated_at => OptionalTimestamp
    }

    @schema.classify_attribute_values(@dj_category)
    @schema.attributes.should == @attributes
  end

  context "merging" do

    it "combines two schemas into one" do
      # FIXME: every time I do anything with Schema it looks more
      # and more like it ought to be a subclass of Hash
      @schema1 = Schema.new({:name => String})
      @schema2 = Schema.new({:title => String})

      @schema1.merge(@schema2)
      @schema1.attributes.should == {:name => String, :title => String}
    end

    context "resolving conflicts by discarding nils" do
      it "works if the other schema has the nil" do
        @schema1 = Schema.new({:name => String})
        @schema2 = Schema.new({:name => nil})

        @schema1.merge(@schema2)
        @schema1.attributes.should == {:name => String}
      end
      it "works if the first schema has the nil" do
        @schema1 = Schema.new({:name => nil})
        @schema2 = Schema.new({:name => String})

        @schema1.merge(@schema2)
        @schema1.attributes.should == {:name => String}
      end
    end
  end

  context "building from multiple instances" do
    it "returns a blank schema if no attributes are specified" do
      @schema = Schema.create_from_many([])
      @schema.attributes.should == {}
    end
    it "merges schemas" do
      instances = [
        Schema.new({:name => String}),
        Schema.new({:title => String}),
        Schema.new({:created_at => OptionalTimestamp}),
        Schema.new({:sold => Boolean})
      ]
      composite = {
        :name => String,
        :title => String,
        :created_at => OptionalTimestamp,
        :sold => Boolean
      }
      schema = Schema.create_from_many(instances)
      schema.attributes.should == composite
    end
  end

end

describe "schema guessing" do

  before do
    # FIXME: all this fixtures bullshit sucks pretty hard
    @goblin_king = { "_id" => BSON::ObjectId('4ed937da7a4f9f200e000037'),
                     "muppet_ids" => [],
                     "kidnapped_children_ids"=>
                        [ BSON::ObjectId('4dc66475d5a52c5756000001'),
                          BSON::ObjectId('4e52f2fddde03222760006d7') ],
                     "created_at" => Time.now,
                     "name" => "Goblin King",
                     "labyrinth" => "magic dance",
                     "private" => true,
                     "slug" => "goblin_king",
                     "updated_at" => Time.now
                   }

    @schema = Schema.new({
      :mongo_id => BSON::ObjectId,
      :muppet_ids => ArrayOfMongoIds,
      :kidnapped_children_ids => ArrayOfMongoIds,
      :created_at => OptionalTimestamp,
      :name => String,
      :private => Boolean,
      :labyrinth => String,
      :slug => String,
      :updated_at => OptionalTimestamp
    })
  end

  it "abstracts a likely schema from an existing element" do
    generated_schema = Schema.extract_from_json(@goblin_king)
    generated_schema.attributes.should == @schema.attributes
  end

  describe "extracting nested schemas" do
    before do
      nested = {"foo" => "bar", "baz" => {"qu" => "ux"}}
      @extracted = Schema.extract_from_json(nested) # it's really extract_from_tree FIXME
    end

    it "deduces schemas contained within schemas" do
      @extracted.attributes[:baz].should be_instance_of Schema
    end

    it "assigns belongs_to correctly when recursively analyzing schemas" do
      @extracted.attributes[:baz].parent_schema.should == @extracted
    end
  end

  it "takes recursive schemas to any arbitrary depth" do
    # a true spec for this requirement would randomize depth and run flawlessly regardless.
    # it would be awesome to write that, but not a huge priority at the moment.
    very_nested = {"first_level" => {"second_level" => {"deep_key" => "deep_value"}}}
    @extracted = Schema.extract_from_json(very_nested) # it's really extract_from_tree FIXME
    @extracted.attributes[:first_level].attributes[:second_level].should be_instance_of Schema
  end
end


