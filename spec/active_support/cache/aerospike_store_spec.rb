describe ActiveSupport::Cache::AerospikeStore do
  it 'should create with default' do
    expect(subject.options).to include :ns
    expect(subject.options[:ns]).to eql 'test'
    expect(subject.options).to include :set
    expect(subject.options[:set]).to eql 'rails_cache'
    expect(subject.options).to include :bin
    expect(subject.options[:bin]).to eql 'data'
    expect(subject.options).to include :timeout
    expect(subject.options[:timeout]).to eql 0.1
  end

  it 'should create with options' do
    store = ActiveSupport::Cache::AerospikeStore.new(ns: 'test2', set: 'rails5', timeout: 5)
    expect(store.options).to include :ns
    expect(store.options[:ns]).to eql 'test2'
    expect(store.options).to include :set
    expect(store.options[:set]).to eql 'rails5'
    expect(store.options).not_to include :host
    expect(store.options).not_to include :port
    expect(store.options).to include :timeout
    expect(store.options[:timeout]).to eql 5
  end

  it 'should clear all entries' do
    subject.clear
    client = Aerospike::Client.new('127.0.0.1', 3000, timeout: 0.1)
    expect(client.query(Aerospike::Statement.new('test', 'test')).records.size).to eql 0
  end

  it 'should return false when error is raised in add of client' do
    client = instance_double Aerospike::Client
    allow(client).to receive(:put).and_raise(Aerospike::Exceptions::Aerospike.new 'test')
    expect(Aerospike::Client).to receive(:new).and_return(client)
    expect(subject.send :write_entry, 'test', ActiveSupport::Cache::Entry.new({a:1}), {}).to eql false
  end
end
