require 'retries'
# This is a basic implementation of the Notification service using Amazon SNS.
# The expected usage is as follows :
#   notification_service = DispatchRider::NotificationServices::AwsSns.new
#   notification_service.publish(:to => [:foo, :oof], :message => {:subject => "bar", :body => "baz"})
module DispatchRider
  module NotificationServices
    class AwsSns < Base
      def notifier_builder
        AWS::SNS
      rescue NameError
        raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
      end

      def channel_registrar_builder
        Registrars::SnsChannel
      end

      def publish_to_channel(channel, message:)
        with_retries(max_retries: 10, rescue: AWS::Errors::MissingCredentialsError) { super }
      end

      # not really happy with this, but the notification service registrar system is way too rigid to do this cleaner
      # since you only can have one notifier for the whole service, but you need to create a new one for each region
      def channel(name)
        arn = self.fetch(name)
        region = arn.split(':')[3]
        notifier_builder.new(region: region).topics[arn]
      end
    end
  end
end
