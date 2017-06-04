RSpec.shared_examples "publish events" do
  AccountCreated = Class.new(FrpEventsourcing::Event)
  MoneyDeposited = Class.new(FrpEventsourcing::Event)
  MoneyWithdrawn = Class.new(FrpEventsourcing::Event)

  let(:publish_account_created_event) do
    event = AccountCreated.new(
      data: {
        account_id: 'LT121000011101001000'
      }
    )
    FrpEventsourcing::EventRepository.new.create(event, :account)
  end

  let(:publish_money_deposited_event) do
    event = MoneyDeposited.new(
      data: {
        account_id: 'LT121000011101001000',
        amount: 100
      }
    )
    FrpEventsourcing::EventRepository.new.create(event, :account)
  end

  let(:publish_big_money_deposited_event) do
    event = MoneyDeposited.new(
      data: {
        account_id: 'LT121000011101001000',
        amount: 1000
      }
    )
    FrpEventsourcing::EventRepository.new.create(event, :account)
  end

  let(:publish_money_withdrawn_event) do
    event = MoneyWithdrawn.new(
      data: {
        account_id: 'LT121000011101001000',
        amount: 25
      }
    )
    FrpEventsourcing::EventRepository.new.create(event, :account)
  end
end
