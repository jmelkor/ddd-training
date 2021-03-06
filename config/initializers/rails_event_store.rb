# frozen_string_literal: true

require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new

  AggregateRoot.configure do |config|
    config.default_event_store = Rails.configuration.event_store
  end

  Rails.configuration.event_store.tap do |store|
    store.subscribe(SeatReservation::ReadModel::SeatReservationReadModel.new, to: [SeatReservation::Events::Created])
    store.subscribe(SeatReservation::ReadModel::PassengerReadModel.new, to: [SeatReservation::Events::PassengerAdded])
    store.subscribe(Flight::ReadModel::FlightReadModel.new, to: [Flight::Events::Scheduled])
    store.subscribe(Notification::ReadModel::Subscribers.new, to: [SeatReservation::Events::PassengerAdded])
  end

  # Subscribe event handlers below
  # Rails.configuration.event_store.tap do |store|
  #   store.subscribe(InvoiceSubscribers.new, to: [InvoicePrinted])
  #   store.subscribe(->(event) { SendOrderConfirmation.new.call(event) }, to: [OrderSubmitted])
  #   store.subscribe_to_all_events(->(event) { Rails.logger.info(event.type) })
  # end

  # Register command handlers below
  # Rails.configuration.command_bus.tap do |bus|
  #   bus.register(PrintInvoice, Invoicing::OnPrint.new)
  #   bus.register(SubmitOrder,  ->(cmd) { Ordering::OnSubmitOrder.new.call(cmd) })
  # end
end
