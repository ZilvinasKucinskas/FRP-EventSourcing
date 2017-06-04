module FrpEventsourcing
  class Map < Stream
    def initialize(source, blk)
      @resource_type = source.resource_type
      @unique_resource_identifier = source.unique_resource_identifier
      @block = blk
      source.add_observer(self)
    end

    def update(event)
      @block.call(event)
      occur(event)
    end
  end
end
