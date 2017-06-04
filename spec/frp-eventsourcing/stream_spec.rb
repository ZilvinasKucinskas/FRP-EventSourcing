require 'spec_helper'

module FrpEventsourcing
  RSpec.describe Stream do
    include_examples "publish events"

    before(:all) do
      account_events_stream =
        Stream.new(AccountCreated, MoneyDeposited, MoneyWithdrawn)

      bonus_money_for_big_deposits =
        Stream.new(MoneyDeposited).
          filter(-> (event) { event[:data][:amount] > 100 }).
          map(-> (event) { event[:data][:amount] *= 0.05 })

      account_read_model =
        account_events_stream.merge(bonus_money_for_big_deposits).
        as_persistent_type(Account, %i(account_id)).
        init(-> (state) { state.balance = 0 }).
        when(MoneyDeposited, -> (state, event) { state.balance += event[:data][:amount] }).
        when(MoneyWithdrawn, -> (state, event) { state.balance -= event[:data][:amount] })
    end

    describe 'transition state' do
      describe 'Init' do
        context 'with first event' do
          before { publish_account_created_event }

          it { expect(Account.first.present?).to be_truthy }
          it { expect(Account.first.balance).to be_zero }
        end

        context 'with other events modifying state' do
          before do
            publish_account_created_event
            publish_money_deposited_event
            publish_account_created_event
          end

          it { expect(Account.first.present?).to be_truthy }
          it { expect(Account.count).to eq(1) }
          it { expect(Account.first.balance).to eq(100) }
        end
      end

      describe 'When' do
        context 'with deposits and withdrawals' do
          before do
            publish_account_created_event
            publish_money_deposited_event
            publish_money_withdrawn_event
          end

          it { expect(Account.first.present?).to be_truthy }
          it { expect(Account.count).to eq(1) }
          it { expect(Account.first.balance).to eq(75) }
        end
      end

      describe 'Merge + Map + Filter(true)' do
        context 'when filter predicate is true' do
          before do
            publish_account_created_event
            publish_money_deposited_event # 100
            publish_big_money_deposited_event # 1000 + 50 bonus = 1050
          end

          it { expect(Account.first.present?).to be_truthy }
          it { expect(Account.count).to eq(1) }
          it { expect(Account.first.balance).to eq(1150) }
        end
      end

      describe 'Filter' do
        context 'when filter does not pass events forward' do
          before do
            publish_account_created_event
            publish_money_deposited_event # 100 and no bonus
          end

          it { expect(Account.first.present?).to be_truthy }
          it { expect(Account.count).to eq(1) }
          it { expect(Account.first.balance).to eq(100) }
        end
      end
    end
  end
end
