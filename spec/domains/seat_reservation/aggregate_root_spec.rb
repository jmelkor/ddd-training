# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeatReservation::AggregateRoot do
  let(:id) { 1 }
  let(:seat_number) { 32 }
  let(:event_store) { RailsEventStore::Client.new }
  let(:event_stream) { "SeatReservation$#{id}" }
  let(:read_model) { SeatReservation::ReadModel }

  def publish_events(*event_classes)
    publish(*event_classes.map(&method(:an_event)))
      .in(event_store)
      .in_stream(event_stream)
  end

  context '#reserve' do
    subject { described_class.new(id).reserve(params: { seat_number: seat_number }) }

    it 'publishes the Reserved event' do
      expect { subject }.to publish_events(SeatReservation::Events::Reserved)
    end
  end

  context '#create_passenger' do
    subject { described_class.new(id).create_passenger(params: passenger_params) }

    let(:passenger_params) { { first_name: 'Gold', last_name: 'Man' } }

    context 'when seat has not been reserved' do
      it 'raises an error' do
        expect { subject }.to raise_error(Core::AggregateRoot::InvalidTransactionError)
      end
    end

    context 'when seat was reserved before' do
      before do
        described_class.new(id).reserve(params: { seat_number: seat_number })
      end

      it 'publishes events' do
        expect { subject }.to(
          publish_events(
            SeatReservation::Events::PassengerDataEntered,
            SeatReservation::Events::PassengerCreated
          )
        )
      end

      it 'creates a passenger' do
        expect { subject }.to change(read_model::Entities::Passenger, :count).by(1)

        expect(read_model::Entities::Passenger.last).to have_attributes(
          first_name: 'Gold',
          last_name: 'Man'
        )
      end

      it 'notify an admin' do
        expect(AdminMailer).to receive(:passenger_created)
          .with(a_hash_including(stream_id: id, passenger: an_instance_of(read_model::Entities::Passenger)))
          .and_call_original

        subject
      end
    end
  end
end