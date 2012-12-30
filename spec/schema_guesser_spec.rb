require 'spec_helper'

describe "schema guessing" do

  before do
    @goblin_king_category = { "_id" => BSON::ObjectId('4ed937da7a4f9f200e000037'),
                     "muppet_ids" => [],
                     "muppet_fan_user_ids"=>
                        [ BSON::ObjectId('4dc66475d5a52c5756000001'),
                          BSON::ObjectId('4e52f2fddde03222760006d7') ],
                     "created_at" => Time.now,
                     "name" => "Goblin King",
                     "private" => true,
                     "slug" => "goblin_king",
                     "updated_at" => Time.now
                   }

    @schema = Schema.new({
      :mongo_id => BSON::ObjectId,
      :muppet_ids => ArrayOfMongoIds,
      :muppet_fan_user_ids => ArrayOfMongoIds,
      :created_at => OptionalTimestamp,
      :name => String,
      :private => Boolean,
      :slug => String,
      :updated_at => OptionalTimestamp
    })
  end

  it "abstracts a likely schema from an existing element" do
    generated_schema = Schema.classify_collection_attributes(@goblin_king_category)
    generated_schema.attributes.should == @schema.attributes
  end
end

