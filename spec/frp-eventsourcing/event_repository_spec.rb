require 'spec_helper'

module FrpEventsourcing
  RSpec.describe EventRepository do
    specify 'initialize with adapter' do
      repository = EventRepository.new
      expect(repository.adapter).to eq(::Event)
    end

    specify 'provide own event implementation' do
      CustomEvent = Class.new(ActiveRecord::Base)
      repository = EventRepository.new(adapter: CustomEvent)
      expect(repository.adapter).to eq(CustomEvent)
    end
  end
end
