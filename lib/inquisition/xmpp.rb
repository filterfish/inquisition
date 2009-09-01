#!/usr/bin/env ruby

require 'zlib'
require 'xmpp4r'
require 'logging'

class XMPPSender
  include Jabber

  def initialize(handle, recipient, password, options={})
    Jabber::debug = options[:debug] if options[:debug]
    @logger = (options[:logger]) ? options[:logger] : Logging.logger(STDOUT)
    @password = password
    @client = client = Client::new(JID::new(handle))
    @recipient = recipient
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
  end

  def send(message, opts={})
    if opts[:compress]
      message = Base64.encode64(Zlib::Deflate.deflate(message))
    end

    message = Message::new(@recipient, message)
    message.type = :chat
    @client.send(message)
  end
end
