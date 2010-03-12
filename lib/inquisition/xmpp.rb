#!/usr/bin/env ruby

require 'zlib'
require 'xmpp4r'
require 'logging'

class XMPPSender
  include Jabber

  def initialize(handle, recipient, password, options={})
    Jabber::debug = options[:debug] if options[:debug]
    @password = password
    @client = client = Client::new(JID::new(handle))
    @recipient = recipient
    @connection_state = :disconnected
  end

  def connect(retries=3, timeout=10)
    begin
      @client.connect
    rescue SocketError => e
      retries = retries - 1
      if retries == 0
        raise
      else
        sleep timeout
        retry
      end
    end

    @client.auth(@password)
    @client.send(Presence.new.set_type(:available))
    @connection_state = :connected
  end

  def send(message, opts={})
    if opts[:compress]
      message = Base64.encode64(Zlib::Deflate.deflate(message))
    end

    message = Message::new(@recipient, message)
    message.type = :chat

    @client.send(message)
  end

  def install_handlers
    # What to do when an exception occurs
    @client.on_exception do |e, client, where|
      if (e.is_a?(Jabber::ServerDisconnected) || e.is_a?(IOError)) && @connection_state == :connected
        @connection_state = :disconnected
        reconnect
      else
        Inquisition::Logging.error(e.message) if e && @connection_state != :disconnected
      end
    end
  end

  private

  def reconnect
    Inquisition::Logging.info("XMPP has gone away. Attempting to reconnect")
    begin
      connect
      Inquisition::Logging.info("Cool. XMPP server is back.")
    rescue Errno::ECONNREFUSED => e
      Inquisition::Logging.info("XMPP server not back yet. Waiting ...")
      sleep 2
      retry
    end
  end
end
