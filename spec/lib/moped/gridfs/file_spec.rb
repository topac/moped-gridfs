require 'spec_helper'
require 'moped/gridfs/file'

require_relative 'write'
require_relative 'read'
require_relative 'getters'
require_relative 'setters'

describe Moped::GridFS::File do

  $chunk_size = 5

  before do
    described_class.any_instance.stub(:default_chunk_size).and_return($chunk_size)
  end

  let(:session) { moped_session }

  let(:bucket) { session.bucket }

  context 'when mode is r' do

    let(:access_mode) { 'r' }

    include_examples :read, :getters

    let(:file) do
      bucket.open("file", "w").write("foobar")
      bucket.open("file", access_mode)
    end

    it 'cannot be written' do
      expect { file.write("foo") }.to raise_error
    end

    it 'does not have setters' do
      %w[content_type metadata aliases filename upload_date].each do |name|
        expect(file).not_to respond_to(:"#{name}=")
      end
    end
  end

  context 'when mode is r+' do

    let(:access_mode) { 'r+' }

    include_examples :read, :getters, :setters
  end

  context 'when mode is w' do

    let(:access_mode) { 'w' }

    include_examples :write, :getters, :setters

    it 'cannot be readed' do
      bucket.open("file", "w").write("foobar")
      file = bucket.open("file", access_mode)
      expect { file.read }.to raise_error
    end
  end

  context 'when mode is w+' do

    let(:access_mode) { 'w+' }

    include_examples :write, :getters, :setters
  end

  context 'when mode is a' do

    let(:access_mode) { 'a' }

    include_examples :write, :getters, :setters
  end

  context 'when mode is a+' do

    let(:access_mode) { 'a+' }

    include_examples :write, :read, :getters, :setters
  end
end
