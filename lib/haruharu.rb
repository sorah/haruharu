require 'rubygems'
require 'json'
require 'socket'

class HaruHaru
  attr_reader :state

  def initialize(addr,port,token)
    @receive_hooks = []
    @state_hooks = []
    @socket = nil
    @thread = nil
    @state = :initialized
    @buffer = nil
    @addr, @port, @token = addr,port,token
  end

  def receive(&block)
    @receive_hooks << block
    self
  end

  def state(&block)
    @state_hooks << block
    self
  end

  def connect
    call_state(:will_connect)
    @socket = TCPSocket.open(@addr,@port)
    call_state(:will_auth)
    @socket.puts "auth #{@token}"
    call_state(:waiting_auth)
    if IO.select([@socket],[],[],10)
      case @socket.gets
      when /^auth good$/
        call_state(:authed)
        start_thread
        call_state(:connected)
      when /^auth bad$/
        raise AuthenticateFailed
        disconnect
      end
    else
      raise AuthenticateTimeout
    end
  end

  def disconnect
    @thread.kill
    @socket.close
    @thread = @socket = nil
    call_state(:disconnected)
  end

  def reconnect
    disconnect
    connect
  end

  class AuthenticateTimeout < Exception; end
  class AuthenticateFailed < Exception; end

  private

  def call_receive(*args)
    @receive_hooks.each{|x| x[*args] }
  end

  def call_state(state)
    @state = state
    @state_hooks.each{|x| x[state] }
  end

  def start_thread; @thread = Thread.new do
    loop do
      if IO.select([@socket],[],[],130)
        _ = @socket.gets
        if _
          _.chomp!
        else
          call_state(:connection_lost)
          Thread.new{reconnect}
          break
        end
        case _
        when /^ping$/
        when /^begin$/
          @buffer = []
        when /^end$/
          call_receive(JSON.parse(@buffer.join))
          @buffer = nil
        else
          next unless @buffer
          @buffer << _
        end
      else
        call_state(:timeout)
        Thread.new{reconnect}
        break
      end
    end
  end; @thread.abort_on_exception = true; end

end
