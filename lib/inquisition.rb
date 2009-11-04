$:.unshift File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'daemons/daemonize'
require 'mq'

require 'inquisition/alerts'
require 'inquisition/checks'
require 'inquisition/config'
require 'inquisition/convertor'
require 'inquisition/limits'
require 'inquisition/logging'
require 'inquisition/xmpp'

require 'inquisition/application/console'
require 'inquisition/application/collector'

VERSION = '0.1.0' unless defined?(VERSION)
