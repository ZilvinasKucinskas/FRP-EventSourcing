require 'securerandom'
require 'observer'

module FrpEventsourcing
  class Event
    extend Observable

    def initialize(event_id: SecureRandom.uuid, metadata: nil, data: nil)
      @event_id = event_id.to_s
      @metadata = metadata.to_h
      @data     = data.to_h
    end
    attr_reader :event_id, :metadata, :data

    def to_h
      {
          event_id:   event_id,
          event_type: self.class,
          metadata:   metadata,
          data:       data
      }
    end

    def ==(other_event)
      other_event.instance_of?(self.class) &&
        other_event.event_id.eql?(event_id) &&
        other_event.data.eql?(data)
    end

    alias_method :eql?, :==

    def emit
      self.class.changed
      self.class.notify_observers(self.to_h)
    end
  end
end
