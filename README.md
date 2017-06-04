[![Build Status](https://travis-ci.org/ZilvinasKucinskas/FRP-EventSourcing.svg?branch=master)](https://travis-ci.org/ZilvinasKucinskas/FRP-EventSourcing)

# Frp-Eventsourcing

EventSourcing describes current state as series of events that occurred in a system. Events hold all information that is needed to recreate current state. This method allows to achieve high volume of transactions, and enables efficient replication. Whereas reactive programming lets implement reactive systems in declarative style, decomposing logic into smaller, easier to understand components. The goal is to create reactive programming program interface, incorporating both principles. Applying reactive programming in event-sourcing systems enables modelling not only instantaneous events, but also have their history. Furthermore, it enables focus on the solvable problem, regardless of low level realization details. Reactive operators enable read model creation without exposing realization details of operations with data storage.

## Sources to learn more about Reactive Programming and EventSourcing

TODO:

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'frp-eventsourcing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frp-eventsourcing

## Usage

### Generate EventStore event model

Use provided task to generate a table to store events in your database.

```
rails generate frp-eventsourcing:migration
rake db:migrate
```

### Event definitions

```
# Define events
AccountCreated = Class.new(FrpEventsourcing::Event)
MoneyDeposited = Class.new(FrpEventsourcing::Event)
MoneyWithdrawn = Class.new(FrpEventsourcing::Event)
```

Alternative definition:

```
class AccountCreated < FrpEventsourcing::Event; end
class MoneyDeposited < FrpEventsourcing::Event; end
class MoneyWithdrawn < FrpEventsourcing::Event; end
```

### Create stream

We can define stream that is creating read model once in our app. Keep in mind that no database operations are present here.

```
account_stream = Cappuccino::Stream.new(AccountCreated, MoneyDeposited, MoneyWithdrawn).
  as_persistent_type(Account, %i(account_id)).
  init(-> (state) { state.balance = 0 }).
  when(MoneyDeposited, -> (state, event) { state.balance += event[:data][:amount] })
  when(MoneyWithdrawn, -> (state, event) { state.balance += event[:data][:amount] })
```

Instead of passing `lambda` directly, we can also use a variable to save and reuse `lambda`:

```
account_initial_state_change_function = -> (state) { state.balance = 0 }
```

or even use a class that implements `call` method. We can structure our code with some kind of denormalizer for example:

```
class Denormalizers::ReadModelType::InitialState::Account
  def call(state)
    state.balance = 0
  end
end
```

### Publish events

We can create an account:

```
stream_name = "account"
event = AccountCreated.new(data: {
          account_id: 'LT121000011101001000'
        })
FrpEventsourcing::EventRepository.new.create(event, stream_name)
```

Transfer some money (100$ for example) to the account:

```
stream_name = "account"
event = MoneyDeposited.new(data: {
          account_id: 'LT121000011101001000',
          amount: 100
        })
FrpEventsourcing::EventRepository.new.create(event, stream_name)
```

Withdraw some money (25$ for example) from the account:

```
stream_name = "account"
event = MoneyWithdrawn.new(data: {
          account_id: 'LT121000011101001000',
          amount: 25
        })
FrpEventsourcing::EventRepository.new.create(event, stream_name)
```

Now we can query read model like:

```
account = Account.find_by(account_id: 'LT121000011101001000')
puts account.balance # prints 75
```

## Available reactive operators

* `merge(another_stream)` - merge one stream to another.
* `filter(predicate_function)` - if predicate function returns false, event won't get propogated through the chain any more.
* `map(transform_function)` - applies transformation function and propogates event through the chain.
* `init(initial_state_change_function)` - applies initial state change function for the first event.
* `when(event_type, state_change_function)` - if event matches event type, record is being created or loaded, state change function is being applied for the record and transition state saved to database.
* `each(state_change_function)` - same as `when` operator, just does not check event type and applies state change function for each event.

## Implementation

Reactive operators were implemented using Observer design pattern, object oriented programming principles and introspection.

Transition state is being solved by applying metaprogramming (introspection, reflection) and using method chaining.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Possible improvements

Easy-medium difficulty:

* Make demo application with UI. Controller should publish events. Event types and streams should be defined in some kind of initializer file for example.
* Improve error handling - could be bugs, because it's just prototype version.
* Refactor event publishing mechanics. We can borrow optimistic locking from [RailsEventStore](https://github.com/arkency/rails_event_store)
* More tests

Challenging:

* Make mechanics for recreating read models after changes. We should reapply all associated events.
* Use custom events repository + instructions how to change adapter for `FrpEventsourcing::EventRepository`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ZilvinasKucinskas/FRP-EventSourcing.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
