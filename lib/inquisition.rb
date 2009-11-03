$:.unshift File.expand_path(File.dirname(__FILE__))

puts File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'mq'
require 'ohai'

require 'inquisition/alerts'
require 'inquisition/checks'
require 'inquisition/config'
require 'inquisition/convertor'
require 'inquisition/limits'
require 'inquisition/logging'
require 'inquisition/xmpp'

require 'inquisition/application/console'
require 'inquisition/application/collector'
