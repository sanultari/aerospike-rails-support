require 'aerospike'

class ActionDispatch::Session::AerospikeStore < ActionDispatch::Session::AbstractStore
  DEFAULT_OPTIONS = {
      host: '127.0.0.1',
      port: 3000,
      ns: 'test',
      set: 'session_rails',
      bin: 'data'
  }

  def initialize(app, options = {})
    options.merge!(DEFAULT_OPTIONS) { |_, old, _| old }
    @client = Aerospike::Client.new(options.delete(:host), options.delete(:port), options)
    options[:expire_after] ||= options[:expiration]
    options[:expire_after] ||= options[:expires_in]
    @options = options.deep_dup
    super
  end

  def get_session(_, sid)
    unless sid and (session = @client.get(key_from(sid, @options)).bins[@options[:bin]])
      sid, session = generate_sid, {}
    end
    [sid, session]
  end

  # Set a session in the cache.
  def set_session(_, sid, session, options)
    merged = options.to_hash.merge!(@options) {|_, old, _| old}
    key = key_from(sid, merged)
    if session
      @client.put(key, Aerospike::Bin.new(merged[:bin], session), expiration: merged[:expire_after])
    else
      @client.delete(key)
    end
    sid
  end

  # Remove a session from the cache.
  def destroy_session(_, sid, options)
    merged = options.to_hash.merge!(@options) {|_, old, _| old}
    @client.delete(key_from(sid, merged), merged)
    generate_sid
  end

  private
  def key_from(name, options)
    Aerospike::Key.new(options[:ns], options[:set], name)
  end
end