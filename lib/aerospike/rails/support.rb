require 'aerospike'
require 'action_dispatch/session/aerospike_store'
require 'active_support/cache/aerospike_store'

Aerospike.logger = Logger.new("/dev/null")
