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

    @mongo_translation_schema = MongoTranslationSchema.new({
      :mongo_id => BSON::ObjectId,
      :muppet_ids => ArrayOfMongoIds,
      :muppet_fan_user_ids => ArrayOfMongoIds,
      :created_at => OptionalTimestamp,
      :name => String,
      :private => Boolean,
      :slug => String,
      :updated_at => OptionalTimestamp
    })

    @random_mongo_objects = RandomMongoObjects.new
    @schema_guesser = SchemaGuesser.new(@random_mongo_objects)
  end

  it "identifies fields, skipping Mongo's reserved _id field" do
    @random_mongo_objects.stub(:next).and_return(@goblin_king_category)
    @schema_guesser.fields.should == [:muppet_ids, :muppet_fan_user_ids, :created_at,
                                      :name, :private, :slug, :updated_at]
  end

  it "returns false when there are no examples" do
    @random_mongo_objects.stub(:next).and_return(nil)
    @schema_guesser.fields.should == false
  end

  it "abstracts a likely schema from an existing element" do
    generated_schema = @schema_guesser.classify_collection_attributes(@goblin_king_category)
    generated_schema.attributes.should == @mongo_translation_schema.attributes
  end
end

