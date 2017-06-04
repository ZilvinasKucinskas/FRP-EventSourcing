require 'observer'

# before we require all of the subclasses, we need to have Stream defined
module FrpEventsourcing
  class Stream
  end
end

require 'frp-eventsourcing/stream/each'
require 'frp-eventsourcing/stream/filter'
require 'frp-eventsourcing/stream/init'
require 'frp-eventsourcing/stream/map'
require 'frp-eventsourcing/stream/when'

module FrpEventsourcing
  class Stream
    include Observable

    UnsupportedPersistentTypeError = Class.new(StandardError)
    PersistentTypeMissingError = Class.new(StandardError)

    attr_reader :resource_type, :unique_resource_identifier

    def initialize(*sources)
      @resource_type = nil
      @unique_resource_identifier = nil

      sources.each do |source|
        source.add_observer(self)
      end
    end

    def update(event)
      occur(event)
    end

    def as_persistent_type(resource_type, unique_resource_identifier = [])
      @resource_type =
        if resource_type.is_a?(String)
          Object.const_set(resource_type, Class.new(ActiveRecord::Base))
        elsif resource_type.is_a?(Symbol)
          Object.const_set(resource_type.to_s.capitalize, Class.new(ActiveRecord::Base))
        elsif resource_type < ActiveRecord::Base
          resource_type
        else
          raise(
            UnsupportedPersistentTypeError,
            'Supported persistent type is String, Symbol or any subclass of ActiveRecord::Base, '\
            "but given: #{resource_type}"
          )
        end

      @unique_resource_identifier =
        if unique_resource_identifier.any?
          unique_resource_identifier
        else
          "#{@resource_type.to_s.downcase}_id"
        end

      return self
    end

    def init(blk)
      Init.new(self, blk)
    end
    alias :inject :init

    def when(event_type, blk)
      When.new(self, event_type, blk)
    end

    def each(blk)
      Each.new(self, blk)
    end

    def map(blk)
      Map.new(self, blk)
    end
    alias :collect :map

    def filter(blk)
      Filter.new(self, blk)
    end
    alias :select :filter

    def merge(another_stream)
      Stream.new(self, another_stream)
    end

    def self.merge(stream_one, stream_two)
      new(stream_one, stream_two)
    end

    protected

    def occur(value)
      changed
      notify_observers(value)
    end

    def extract_entity_id(event)
      event[:data].slice(*@unique_resource_identifier)
    end

    def check_resource_type_presence
      return if resource_type

      raise(
        PersistentTypeMissingError,
        'Persistent type missing. Make sure to call #as_persistent_type method on stream.'
      )
    end
  end
end
