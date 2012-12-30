module Argonaut

  class RandomMongoObjects

    attr_reader :collection

    def collection=(name)
      # you sort of have to call this method for anything in here to be useful
      @collection = @database[name]
      @example = nil # reset, because of memoization in #fields()
    end

    def next
      # not under spec because it's really just a Mongo query. translated from:
      # http://stackoverflow.com/questions/2824157/random-record-from-mongodb
      @collection.find.limit(-1).skip(rand(@collection.count - 1)).next
    end

    def each &block
      @collection.find.each &block
    end

    def initialize
      config = YAML.load_file "mongo.yml"

      @connection = Mongo::Connection.new config["host"], config["port"], :slave_ok => true
      @database = @connection[config["database"]]
      @database.authenticate(config["user"], config["password"])
    end

  end

end
