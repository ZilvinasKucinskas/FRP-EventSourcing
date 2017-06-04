module FrpEventsourcing
  class Init < Stream
    def initialize(source, blk)
      @resource_type = source.resource_type
      @unique_resource_identifier = source.unique_resource_identifier
      @block = blk
      source.add_observer(self)
    end

    def update(event)
      check_resource_type_presence

      entity_id_hash = extract_entity_id(event)

      if !@resource_type.where(entity_id_hash).exists?
        resource = @resource_type.new(event[:data])
        @block.call(resource)
        resource.save!
      end

      occur(event)
    end
  end
end
