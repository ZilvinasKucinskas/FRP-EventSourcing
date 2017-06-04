module FrpEventsourcing
  class Filter < Stream
    def initialize(source, blk)
      @resource_type = source.resource_type
      @unique_resource_identifier = source.unique_resource_identifier
      @block = blk
      source.add_observer(self)
    end

    def update(event)
      occur(event) if @block.call(event)
    end
  end
end
