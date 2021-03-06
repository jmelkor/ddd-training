# frozen_string_literal: true

module SeatReservation
  module Events
    class Created < RailsEventStore::Event
      def self.strict(data)
        new(data: { params: data[:params], stream_id: data[:stream_id] })
      end
    end

    class PassengerAdded < RailsEventStore::Event
      def self.strict(data)
        new(data: { params: data[:params], stream_id: data[:stream_id] })
      end
    end

    class Paid < RailsEventStore::Event
      def self.strict(data)
        new(data: { params: nil, stream_id: data[:stream_id] })
      end
    end
  end
end
