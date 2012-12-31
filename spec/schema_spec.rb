require 'spec_helper'

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

