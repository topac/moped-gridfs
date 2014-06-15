require 'spec_helper'
require 'moped/gridfs/bucket'

describe Moped::GridFS::Bucket do

  let(:session) { moped_session }

  describe '#initialize' do

    context 'when the given name is empty' do

      it 'raises an error' do
        expect { described_class.new(session, '') }.to raise_error
      end
    end

    context 'when the given name is nil' do

      it 'raises an error' do
        expect { described_class.new(session, nil) }.to raise_error
      end
    end

    context 'when the given name is not empty nor nil' do

      it 'does not raise any error' do
        expect { described_class.new(session, 'foo') }.not_to raise_error
      end
    end
  end

  let(:subject) { described_class.new(session, 'bar') }

  describe '#files' do

    it 'returns an enumerable' do
      expect(subject.files).to respond_to(:each)
    end
  end

  describe '#drop' do

    before do
      subject.files_collection.insert(foo: 'bar')
      subject.chunks_collection.insert(foo: 'bar')
    end

    it 'drops the two collections' do
      subject.drop

      expect(subject.files_collection.find.count).to eq(0)
      expect(subject.chunks_collection.find.count).to eq(0)
    end
  end

  describe '#delete' do

    context 'when a file is missing' do

      it 'returns nil' do
        expect(subject.delete("file")).to be_nil
      end
    end

    context 'when a file exists' do

      before do
        subject.open("file", "w").write("buffer")
      end

      it 'returns nil' do
        expect(subject.delete("file")).to be_nil
      end

      it 'deletes the file' do
        subject.delete("file")
        expect { subject.open("foo", "r") }.to raise_error
      end
    end
  end

  describe '#open' do

    context 'when the mode is w' do

      it 'returns a writable file' do
        expect(subject.open("foo", "w")).to be_writable
      end
    end

    context 'when the mode is r' do

      context 'and the file is missing' do

        it 'raises an error' do
          expect { subject.open("foo", "r") }.to raise_error
        end
      end

      context 'and the file exists' do

        before do
          subject.open("bar", "w").write("buffer")
        end

        it 'returns a readable file' do
          expect(subject.open("bar", "r")).to be_readable
        end
      end
    end

    context 'when the mode is a' do

      it 'returns a writable file' do
        expect(subject.open("foo", "a")).to be_writable
      end
    end
  end
end
