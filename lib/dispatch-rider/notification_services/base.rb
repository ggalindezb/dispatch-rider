# This base class provides an interface that we can implement
# to generate a wrapper around a notification service.
# The expected usage is as follows :
#   notification_service = DispatchRider::NotificationServices::Base.new
#   notification_service.publish(:to => [:foo, :oof], :message => {:subject => "bar", :body => "baz"})

require 'forwardable'

module DispatchRider
  module NotificationServices
    class Base
      extend Forwardable

      attr_reader :notifier, :channel_registrar

      def_delegators :channel_registrar, :register, :fetch, :unregister

      def initialize(options = {})
        @notifier = notifier_builder.new(options)
        @channel_registrar = channel_registrar_builder.new
      end

      def notifier_builder
        raise NotImplementedError
      end

      def channel_registrar_builder
        raise NotImplementedError
      end

      def publish(options)
        channels(options[:to]).each do |channel|
          channel.publish(serialize(options[:message]))
        end
      end

      def channels(names)
        Array(names).map { |name| channel(name) }
      end

      def channel(name)
        raise NotImplementedError
      end

      private

      def serialize(item)
        item.to_json
      end
    end
  end
end
