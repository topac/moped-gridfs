require 'spec_helper'

shared_examples :read do

  context '#read' do

    context 'when the file is empty' do

      before do
        bucket.open("file", "w").write('')
      end

      it 'returns an empty string' do
        expect(bucket.open("file", access_mode).read).to eq('')
      end
    end

    ["a", "\xE9a", "a"*($chunk_size-1), "a"*$chunk_size, "a"*($chunk_size)+"b"].each do |buffer|

      before { buffer.force_encoding('BINARY') }

      context "given a file #{buffer.size}-byte(s) long" do

        let!(:file) do
          bucket.open("file", "w").write(buffer)
          file = bucket.open("file", access_mode)
          file.rewind if file.append?
          file
        end

        it 'changes the position' do
          (1..buffer.size).to_a.concat([buffer.size*2]) do |i|
            file.rewind
            expect(file.read(i)).to eq(buffer[0..i - 1])
          end
        end

        context "when called without args" do

          it 'returns the whole file content' do
            expect(file.read).to eq(buffer)
          end
        end

        context "when called multiple times to read some bytes each time" do

          it 'returns the expected data' do
            data = []
            data << file.read(1) until file.eof?
            expect(data.size).to eq(buffer.size)
            expect(data.join).to eq(buffer)
          end

          it 'changes the position' do
            readed = 0
            steps = []
            2.times { steps << buffer.size / 2 }
            steps << buffer.size % 2

            steps.each_with_index do |size, index|
              file.read(size)
              expect(file.pos).to eq(readed += size)
            end
          end
        end

        context 'when zero is passed' do

          it 'returns an empty string' do
            expect(file.read(0)).to eq('')
          end

          it 'does not change the position' do
            file.read(0)
            expect(file.pos).to be_zero
          end
        end

        context 'when a negative number is passed' do

          before { file.read(1) }

          it 'raises an error' do
            expect { file.read(-1) }.to raise_error
          end

          it 'does not change the position' do
            expect(file.pos).to eq(1)
          end
        end

        context "when an integer is passed" do

          it 'returns the content of the file up to the given position' do
            expect(file.read(buffer.size * 2)).to eq(buffer)

            (1..buffer.size).to_a do |i|
              file.rewind
              expect(file.read(i)).to eq(buffer[0..i - 1])
            end
          end
        end
      end
    end
  end
end
