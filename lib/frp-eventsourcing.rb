require 'frp-eventsourcing/version'
require 'frp-eventsourcing/generators/migration_generator'
require 'frp-eventsourcing/event'
require 'frp-eventsourcing/event_repository'
require 'frp-eventsourcing/stream'

class EventStoreEvent < ::ActiveRecord::Base
  self.primary_key = :id

  serialize :metadata
  serialize :data
end
