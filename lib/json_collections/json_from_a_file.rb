class JSONFromAFile
  def load(filename)
    @loaded = ParsedJson.new(JSON.parse File.read(filename))
  end

  # require 'delegate' ?
  def each &block
    @loaded.each &block
  end

  def next
    @loaded.next
  end
end

