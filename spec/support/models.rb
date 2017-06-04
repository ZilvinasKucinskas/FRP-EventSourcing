class Event < ActiveRecord::Base
  self.table_name = 'event_store_events'

  serialize :metadata
  serialize :data
end

class Account < ActiveRecord::Base
end
