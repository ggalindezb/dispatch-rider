# This class is responsible for dispatching the messages to the appropriate handler.
# The handlers must be registered with the dispatcher.
# Tha handlers need to be modules that implement the process method.
# What handler to dispatch the message to is figured out from the subject of the message.

module DispatchRider
  class Dispatcher
    extend Forwardable

    require 'dispatch-rider/dispatcher/named_process'
    include NamedProcess

    attr_reader :handler_registrar

    def_delegators :handler_registrar, :register, :fetch, :unregister

    def initialize
      @handler_registrar = Registrars::Handler.new
    end

    def dispatch(message)
      with_named_process(message.subject) do
        handler_registrar.fetch(message.subject).process(message.body)
      end

      true # success => true (delete message)
    end

  end
end
