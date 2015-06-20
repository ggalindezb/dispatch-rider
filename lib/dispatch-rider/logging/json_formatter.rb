require 'json'

# JSON Log Formatter
module DispatchRider
  module Logging
    class JsonFormatter < BaseFormatter
      # @param [DispatchRider::QueueServices::ReceivedMessage] message
      # @param [Exception] exception
      # @return [String] JSON representation of the log item
      def format_error_handler_fail(message, exception)
        as_json do
          {
            phase: :failed,
          }.merge exception_info_fragment(message, exception)
        end
      end

      # @param [DispatchRider::QueueServices::ReceivedMessage] message
      # @param [String] reason
      # @return [String] JSON representation of the log item
      def format_got_stop(message, reason)
        as_json do
          {
            phase: :stop,
            reason: reason,
          }.merge message_info_fragment(message)
        end
      end

      # @param [Symbol] kind of log action. one of: :start, :success, :fail, :complete
      # @param [DispatchRider::QueueServices::ReceivedMessage] message
      # @param [Exception] exception
      # @param [Float] Job execution duration
      # @return [String] JSON representation of the log item
      def format_handling(kind, message, exception: nil, duration: nil)
        as_json do
          case kind
          when :start
            message_info_fragment(message)
          when :success
            message_info_fragment(message)
          when :fail
            exception_info_fragment(message, exception)
          when :complete
            { duration: format_duration(duration) }.merge message_info_fragment(message)
          end.merge(phase: kind)
        end
      end

      private

      def as_json
        JSON.generate yield
      end

      def message_info_fragment(message)
        {
          guid: message.guid.to_s,
          subject: message.subject,
          body: message_info_arguments(message),
        }
      end

      def exception_info_fragment(message, exception)
        exception_details = {
          expection: {
            class: exception.class.to_s,
            message: exception.message,
          }
        }
        message_info_fragment(message).merge exception_details
      end
    end
  end
end