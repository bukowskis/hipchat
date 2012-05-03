require 'ostruct'

require 'hipchat/railtie' if defined?(Rails::Railtie)
require 'hipchat/connection'
require 'em-http'
require 'json'

module HipChat
  class UnknownRoom         < StandardError; end
  class Unauthorized        < StandardError; end
  class UnknownResponseCode < StandardError; end

  class Client

    def connection
      @conn
    end
    
    def initialize(token, options = {})
      @token = token
      @conn = HipChat::Connection.create options
    end

    def rooms
      response = @conn.get("list", :auth_token => @token)
      @rooms ||= JSON.parse(response.body)['rooms'].
        map { |r| Room.new(@conn, @token, r) }
    end

    def [](name)
      Room.new(@conn, @token, :room_id => name)
    end
  end

  class Room < OpenStruct

    def initialize(conn, token, params)
      @conn = conn
      @token = token
      super(params)
    end

    # Send a message to this room.
    #
    # Usage:
    #
    #   # Default
    #   send 'nickname', 'some message'
    #
    #   # Notify users and color the message red
    #   send 'nickname', 'some message', :notify => true, :color => 'red' 
    #
    #   # Notify users (deprecated)
    #   send 'nickname', 'some message', true
    #
    # Options:
    #
    # +color+::  "yellow", "red", "green", "purple", or "random"
    #            (default "yellow")
    # +notify+:: true or false
    #            (default false)
    def send(from, message, options_or_notify = {:notify => false})
      options = if options_or_notify == true or options_or_notify == false
        warn "DEPRECATED: Specify notify flag as an option (e.g., :notify => true)"
        { :notify => options_or_notify }
      else
        options_or_notify || {}
      end

      options = { :color => 'yellow', :notify => false }.merge options

      response = @conn.post do |request|
        request.url 'message', :auth_token => @token
        request.body = {
          :room_id => room_id,
          :from    => from,
          :message => message,
          :color   => options[:color],
          :notify  => options[:notify] ? 1 : 0
        }
      end
      case response.status
      when 200; true
      when 404
        raise UnknownRoom,  "Unknown room: `#{room_id}'"
      when 401
        raise Unauthorized, "Access denied to room `#{room_id}'"
      else
        raise UnknownResponseCode, "Unexpected #{response.status} for room `#{room_id}'"
      end
    end

  end

end
