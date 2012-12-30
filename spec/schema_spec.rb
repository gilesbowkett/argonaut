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

  it "belongs to another Schema" do
    owned_schema = Schema.new
    owned_schema.belongs_to @schema
    owned_schema.parent_schema.should == @schema
  end

  it "deduces schemas contained within schemas" do
    nested = {"foo" => "bar", "baz" => {"qu" => "ux"}}
    extracted = Schema.extract_from_json(nested) # it's really extract_from_tree
    extracted.attributes[:baz].should be_instance_of Schema
  end

  it "assigns belongs_to correctly when recursively analyzing schemas"
end

