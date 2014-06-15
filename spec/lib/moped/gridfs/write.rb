require 'spec_helper'

shared_examples :write do

  describe '#write' do
    ["a", "\xE9a", "a"*($chunk_size-1), "a"*$chunk_size, "a"*($chunk_size)+"b"].each do |buffer|

      before { buffer.force_encoding('BINARY') }

      pos1 = buffer.size + rand(1..$chunk_size*2)

      pos2 = rand(0..buffer.size-1)

      context "given a #{buffer.size}-byte(s) long buffer" do

        context "when start from a position greater (#{pos1}) than the file length" do

          let(:file) { bucket.open("file", access_mode) }

          before do
            file.write(buffer)
            file.seek(pos1)
            file.write(buffer)
          end

          it 'writes the data' do
            expect(bucket.open("file", "r").read).to eq(buffer * 2)
          end

          it 'updates the length' do
            expect(file.length).to eq(buffer.size * 2)
          end

          it 'updates the position' do
            expect(file.pos).to eq(buffer.size * 2)
          end

          it 'updates the md5' do
            expect(file.md5).to eq(Digest::MD5.hexdigest(buffer+buffer))
          end

          it 'writes the length attributes' do
            expect(bucket.open("file", "r").length).to eq(buffer.size * 2)
          end
        end

        context "when start from a position (#{pos2}) lesser than the file length" do

          let(:file) { bucket.open("file", access_mode) }

          let(:buffer2) { 'data' }

          before do
            file.write(buffer)
            file.seek(pos2)
            file.write(buffer2)
          end

          let(:expected) do
            if file.append?
              buffer + buffer2
            else
              s = buffer2.size
              pos2.zero? ? "#{buffer2}#{buffer[s..-1]}" : "#{buffer[0..pos2-1]}#{buffer2}#{buffer[pos2+s..-1]}"
            end
          end

          it 'write the data' do
            expect(bucket.open("file", "r").read).to eq(expected)
          end

          it 'updates the length' do
            expect(file.length).to eq(expected.size)
          end

          it 'updates the position' do
            expected_pos = file.append? ? buffer.size + buffer2.size : pos2 + buffer2.size
            expect(file.pos).to eq(expected_pos)
          end

          it 'updates the md5' do
            expect(file.md5).to eq(Digest::MD5.hexdigest(expected))
          end

          it 'writes the length attributes' do
            expect(bucket.open("file", "r").length).to eq(expected.size)
          end
        end

        context 'when start from a non-zero position' do

          let(:file) { bucket.open("file", access_mode) }

          before do
            file.seek($chunk_size * 3)
            file.write(buffer)
          end

          it 'writes from the start' do
            expect(bucket.open("file", "r").read).to eq(buffer)
          end

          it 'updates the length' do
            expect(file.length).to eq(buffer.size)
          end

          it 'updates the position' do
            expect(file.pos).to eq(buffer.size)
          end

          it 'updates the md5' do
            expect(file.md5).to eq(Digest::MD5.hexdigest(buffer))
          end

          it 'writes the length attributes' do
            expect(bucket.open("file", "r").length).to eq(buffer.size)
          end
        end

        (1..5).each do |n|
          context "when is written #{n} times" do
            let(:file) { bucket.open("file", access_mode) }

            before do
              n.times { file.write(buffer) }
            end

            it 'writes the data' do
              expect(bucket.open("file", "r").read).to eq(buffer*n)
            end

            it 'writes the length attributes' do
              expect(bucket.open("file", "r").length).to eq(buffer.size*n)
            end

          it 'updates the md5' do
            expect(file.md5).to eq(Digest::MD5.hexdigest(buffer*n))
          end

            it 'updates the length' do
              expect(file.length).to eq(buffer.size*n)
            end

            it 'updates the position' do
              expect(file.pos).to eq(buffer.size*n)
            end
          end
        end
      end
    end
  end
end
