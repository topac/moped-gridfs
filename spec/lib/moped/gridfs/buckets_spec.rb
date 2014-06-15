require 'spec_helper'
require 'moped/gridfs/buckets'

describe Moped::GridFS::Buckets do

  let(:session) { moped_session }

  let(:subject) { described_class.new(session) }

  before do
    Moped::GridFS::Bucket.new(session, "bar").open("file", "w")
    Moped::GridFS::Bucket.new(session, "foo").open("file", "w")
  end

  describe '#names' do

    it 'returns the bucket names' do
      expect(subject.names.sort).to eq(%w[bar foo])
    end
  end

  describe '#count' do

    it 'returns the buckets count' do
      expect(subject.count).to eq(2)
    end
  end

  describe '#[]' do

    it 'returns a bucket with the given name' do
      bucket = subject['test']
      expect(bucket.name).to eq('test')
    end
  end

  describe '#each' do

    it 'iterates over the buckets' do
      names = []
      subject.each { |bucket| names << bucket.name }
      expect(names.sort).to eq(%w[bar foo])
    end
  end
end
