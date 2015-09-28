require 'aerospike'

module ActiveSupport
  module Cache
    class AerospikeStore < Store
      DEFAULT_OPTIONS = {
          ns: 'test',
          set: 'rails_cache',
          bin: 'data',
          host: '127.0.0.1',
          port: 3000,
          timeout: 0.1,
          ttl: 60,
          unless_exist: false
      }

      def initialize(options = {})
        options.merge!(DEFAULT_OPTIONS) { |_, user, _| user }
        @client = Aerospike::Client.new(options.delete(:host), options.delete(:port), options.dup)
        super
      end

      def clear(options = nil)
        @client.query(Aerospike::Statement.new(@options[:ns], @options[:set])).each do |entry|
          @client.delete(entry.key)
        end
      end

      def increment(name, amount = 1, options = nil)
        options = merged_options(options)
        instrument(:increment, name, amount: amount) do
          @client.add(key_from(namespaced_key(name, options), options), Aerospike::Bin.new(@options[:bin], amount))
        end
      end

      def decrement(name, amount = 1, options = nil)
        options = merged_options(options)
        instrument(:decrement, name, amount: amount) do
          @client.add(key_from(namespaced_key(name, options), options), Aerospike::Bin.new(@options[:bin], (amount * -1)))
        end
      end

      protected
      def read_entry(key, options) # :nodoc:
        value = @client.get(key_from(key, options))
        return nil if value.nil?
        Entry.new(@client.get(key_from(key, options)).bins[options[:bin]])
      rescue Aerospike::Exceptions::Aerospike => e
        Rails.logger.error e if defined? Rails
        nil
      end

      def write_entry(key, entry, options) # :nodoc:
        options = merged_options(options)
        options[:expiration] ||= options[:expires_in] if options.include? :expires_in
        options[:expiration] ||= options[:ttl] if options.include? :ttl
        options[:record_exists_action] ||= options[:unless_exist]? Aerospike::RecordExistsAction::CREATE_ONLY : Aerospike::RecordExistsAction::REPLACE
        data = Aerospike::Bin.new(options[:bin], entry.value)
        @client.put key_from(key, options), data, options
        true
      rescue Aerospike::Exceptions::Aerospike => e
        Rails.logger.error e if defined? Rails
        false
      end

      def delete_entry(key, options) # :nodoc:
        @client.delete(key_from(key, options))
      rescue Aerospike::Exceptions::Aerospike => e
        Rails.logger.error e if defined? Rails
      end

      private
      def key_from(key, options)
        Aerospike::Key.new(options[:ns], options[:set], key)
      end
    end
  end
end
