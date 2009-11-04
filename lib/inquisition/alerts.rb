module Inquisition
  module Alerts
    class XMPP
      def initialize(config)
        @xmpp = XMPPSender.new(config[:sender_jid], config[:recipient_jid], config[:sender_passwd])
        @xmpp.connect
      end

      def send(message)
        @xmpp.send(message)
      end
    end
  end
end
