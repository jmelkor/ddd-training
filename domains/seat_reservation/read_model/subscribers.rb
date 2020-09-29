# frozen_string_literal: true

module SeatReservation
  module ReadModel
    class Subscribers
      def call(event)
        case event
        when SeatReservation::Events::PassengerDataEntered
          passenger_data_entered(event.data)
        end
      end

      private

      def passenger_data_entered(payload)
        Actions::CreatePassenger.new(
          stream_id: payload[:stream_id],
          params: payload[:params]
        ).call
      end
    end
  end
end
