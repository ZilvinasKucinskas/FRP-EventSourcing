module FrpEventsourcing
  class When < Stream
    def initialize(source, event_type, blk)
      @resource_type = source.resource_type
      @unique_resource_identifier = source.unique_resource_identifier
      @block = blk
      @event_type = event_type
      source.add_observer(self)
    end

    def update(event)
      check_resource_type_presence

      if event[:event_type] == @event_type
        entity_id_hash = extract_entity_id(event)

        resource =
          if !@resource_type.where(entity_id_hash).exists?
            @resource_type.new
          else
            @resource_type.where(entity_id_hash).first
          end

        @block.call(resource, event)
        resource.save!
      end

      occur(event)
    end
  end
end
