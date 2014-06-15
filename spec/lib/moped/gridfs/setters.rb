require 'spec_helper'

shared_examples :setters do

  before do
    file = bucket.open("file", "w")
    file.write("foobar")
    file.metadata = {pdf: true}
  end

  let(:file) { bucket.open("file", access_mode) }

  let(:truncate_mode) { file.__send__(:truncate?) }

  describe '#length=' do

    it 'is not defined' do
      expect(file).not_to respond_to(:length=)
    end
  end

  describe '#content_type=' do

    before { file.content_type = "foo" }

    it 'changes the contentType attribute in memory' do
      expect(file.content_type).to eq("foo")
    end

    it 'changes the contentType attribute on disk' do
      expect(bucket.open("file", "r").content_type).to eq("foo")
    end
  end

  describe '#contentType=' do

    it 'is not defined' do
      expect(file).not_to respond_to(:contentType=)
    end
  end

  describe '#chunk_size=' do

    it 'is not defined' do
      expect(file).not_to respond_to(:chunk_size=)
    end
  end

  describe '#chunkSize=' do

    it 'is not defined' do
      expect(file).not_to respond_to(:chunkSize=)
    end
  end

  describe '#filename=' do

    before { file.filename = "foo" }

    it 'changes the contentType attribute in memory' do
      expect(file.filename).to eq("foo")
    end

    it 'changes the contentType attribute on disk' do
      expect { bucket.open("foo", "r") }.not_to raise_error
    end
  end

  describe '#md5=' do

    it 'is not defined' do
      expect(file).not_to respond_to(:md5=)
    end
  end


  describe '#metadata=' do

    let(:metadata) { {key: 'value'} }

    before { file.metadata = metadata }

    it 'changes the contentType attribute in memory' do
      expect(file.metadata).to eq(metadata)
    end

    it 'changes the contentType attribute on disk' do
      expect(bucket.open("file", "r").metadata).to eq('key' => 'value')
    end
  end

  describe '#uploadDate=' do

    it 'is not defined' do
      expect(file).not_to respond_to(:uploadDate=)
    end
  end

  describe '#upload_date=' do

    let(:now) { Time.new(2013,01,01).utc }

    before { file.upload_date = now }

    it 'changes the contentType attribute in memory' do
      expect(file.upload_date).to eq(now)
    end

    it 'changes the contentType attribute on disk' do
      expect(bucket.open("file", "r").upload_date).to eq(now)
    end
  end
end
