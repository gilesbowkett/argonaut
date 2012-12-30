require 'spec_helper'

describe ImplicitJSONSchema do

  before do
    @implicit_json_schema = ImplicitJSONSchema.new
  end

  it "classifies Mongo ID fields" do
    @implicit_json_schema.classify_attribute_value("_id" => BSON::ObjectId('4ed937da7a4f9f200e000037'))
    @implicit_json_schema.attributes.should == {:mongo_id => BSON::ObjectId}
  end
  it "classifies Mongo ID arrays when the array contains Mongo IDs" do
    array_of_ids = {"muppet_fan_user_ids"=> [ BSON::ObjectId('4dc66475d5a52c5756000001'),
                                              BSON::ObjectId('4e52f2fddde03222760006d7') ]}
    @implicit_json_schema.classify_attribute_value(array_of_ids)
    @implicit_json_schema.attributes.should == {:muppet_fan_user_ids => ArrayOfMongoIds}
  end
  it "isn't fooled by arrays with varied classes in them" do
    mixed_array = {"muppet_fan_user_ids"=> [ BSON::ObjectId('4dc66475d5a52c5756000001'),
                                            7 ]}
    @implicit_json_schema.classify_attribute_value(mixed_array)
    @implicit_json_schema.attributes.should == {:muppet_fan_user_ids => Array}
  end
  it "classifies Mongo ID arrays when the array's empty and named *_ids" do
    @implicit_json_schema.classify_attribute_value("muppet_ids" => [])
    @implicit_json_schema.attributes.should == {:muppet_ids => ArrayOfMongoIds}
  end

  context "with Mongo objects" do
    before do
      @foobar = BSON::OrderedHash.new
      @foobar["foo"] = "bar"
    end

    it "classifies arrays of Mongo objects" do
      @implicit_json_schema.classify_attribute_value("fraggles" => [@foobar])
      @implicit_json_schema.attributes.should == {:fraggles => ArrayOfMongoObjects}
    end

    it "preserves Mongo objects for later recursive analysis" do
      @implicit_json_schema.classify_attribute_value("dark_crystal" => @foobar)
      @implicit_json_schema.attributes.should == {:dark_crystal => @foobar}
    end
  end

  it "classifies optional timestamps" do
    @implicit_json_schema.classify_attribute_value("created_at" => Time.now)
    @implicit_json_schema.attributes.should == {:created_at => OptionalTimestamp}
  end

  it "classifies falses as booleans" do
    @implicit_json_schema.classify_attribute_value("private" => false)
    @implicit_json_schema.attributes.should == {:private => Boolean}
  end

  it "classifies trues as booleans" do
    @implicit_json_schema.classify_attribute_value("private" => true)
    @implicit_json_schema.attributes.should == {:private => Boolean}
  end

  it "classifies strings" do
    @implicit_json_schema.classify_attribute_value("name" => "Goblin King")
    @implicit_json_schema.attributes.should == {:name => String}
  end

  it "classifies integers" do
    @implicit_json_schema.classify_attribute_value("number_of_hats" => 5)
    @implicit_json_schema.attributes.should == {:number_of_hats => Fixnum}
  end

  it "classifies floats" do
    @implicit_json_schema.classify_attribute_value("price" => 70.0)
    @implicit_json_schema.attributes.should == {:price => Float}
  end

  it "skips nulls" do
    @implicit_json_schema.classify_attribute_value("number_of_hats" => nil)
    @implicit_json_schema.attributes.should == {:number_of_hats => nil}
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

    @implicit_json_schema.classify_attribute_values(@dj_category)
    @implicit_json_schema.attributes.should == @attributes
  end

  context "merging" do

    it "combines two schemas into one" do
      # FIXME: every time I do anything with ImplicitJSONSchema it looks more
      # and more like it ought to be a subclass of Hash
      @schema1 = ImplicitJSONSchema.new({:name => String})
      @schema2 = ImplicitJSONSchema.new({:title => String})

      @schema1.merge(@schema2)
      @schema1.attributes.should == {:name => String, :title => String}
    end

    context "resolving conflicts by discarding nils" do
      it "works if the other schema has the nil" do
        @schema1 = ImplicitJSONSchema.new({:name => String})
        @schema2 = ImplicitJSONSchema.new({:name => nil})

        @schema1.merge(@schema2)
        @schema1.attributes.should == {:name => String}
      end
      it "works if the first schema has the nil" do
        @schema1 = ImplicitJSONSchema.new({:name => nil})
        @schema2 = ImplicitJSONSchema.new({:name => String})

        @schema1.merge(@schema2)
        @schema1.attributes.should == {:name => String}
      end
    end
  end

  context "building from multiple instances" do
    it "returns a blank schema if no attributes are specified" do
      @schema = ImplicitJSONSchema.create_from_many([])
      @schema.attributes.should == {}
    end
    it "merges schemas" do
      instances = [
        ImplicitJSONSchema.new({:name => String}),
        ImplicitJSONSchema.new({:title => String}),
        ImplicitJSONSchema.new({:created_at => OptionalTimestamp}),
        ImplicitJSONSchema.new({:sold => Boolean})
      ]
      composite = {
        :name => String,
        :title => String,
        :created_at => OptionalTimestamp,
        :sold => Boolean
      }
      schema = ImplicitJSONSchema.create_from_many(instances)
      schema.attributes.should == composite
    end
  end

end
