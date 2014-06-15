require 'spec_helper'

shared_examples :getters do

  before do
    file = bucket.open("file", "w")
    file.write("foobar")
    file.metadata = {pdf: true}
  end

  let(:file) { bucket.open("file", access_mode) }

  let(:truncate_mode) { file.__send__(:truncate?) }

  describe '#length' do

    it 'returns the file length' do
      expect(file.length).to eq(truncate_mode ? 0 : 6)
    end
  end

  describe '#content_type' do

    it 'returns the contentType value' do
      expect(file.content_type).to eq('application/octet-stream')
    end
  end

  describe '#chunk_size' do

    it 'returns the file chunk size' do
      expect(file.chunk_size).to eq(file.default_chunk_size)
    end
  end

  describe '#filename' do

    it 'returns the file chunk size' do
      expect(file.filename).to eq("file")
    end
  end

  describe '#md5' do

    it 'returns the file chunk size' do
      expected = Digest::MD5.hexdigest("foobar")
      expect(file.md5).to eq(truncate_mode ? nil : expected)
    end
  end

  describe '#metadata' do
    it 'returns the file metadata' do
      expected = {'pdf' => true}
      expect(file.metadata).to eq(truncate_mode ? Hash.new : expected)
    end
  end

  describe '#contentType' do

    it 'is not defined' do
      expect(file).not_to respond_to(:contentType)
    end
  end

  describe '#chunkSize' do

    it 'is not defined' do
      expect(file).not_to respond_to(:chunkSize)
    end
  end

  describe '#uploadDate' do

    it 'is not defined' do
      expect(file).not_to respond_to(:uploadDate)
    end
  end
end
