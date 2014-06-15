# Compare with mongo-ruby-driver
# $ gem install mongo
# $ gem install bson_ext

$INCLUDE_MONGO = true

require_relative 'perf_helper'

def reset
  purge

  @bucket = moped_session.bucket
  @grid = Mongo::GridFileSystem.new(mongo_connection)
end

def content(size = 0.5) # 0.5 mb
  "\xDF\x00\xAB\xFA" * (1024 * 1024 * size)
end

profile("Create an empty file", n: [1000, 5_000]) do |bm, n|
  reset

  bm.report do
    n.times { |i| @bucket.open("file#{i}", 'w') }
  end

  reset

  bm.report do
    n.times { |i| @grid.open( "file#{i}", 'w').close }
  end
end

profile("Create and write a file", n: [10, 100]) do |bm, n|
  reset

  bm.report do
    n.times { |i| @bucket.open("file#{i}", 'w').write(content) }
  end

  reset

  bm.report do
    n.times do |i|
      file = @grid.open("file", "w")
      file.write(content)
      file.close
    end
  end
end

profile("Sequentially write on a file", n: [1000, 5_000]) do |bm, n|
  reset
  file = @bucket.open("file", 'w')

  bm.report do
    n.times { |i| file.write("foobar") }
  end

  reset
  file = @grid.open("file", "w")

  bm.report do
    (n-1).times { |i| file.write("foobar") }
    file.close
  end
end

profile("Open a file in r mode", n: [1000, 5_000]) do |bm, n|
  reset
  @bucket.open("file", 'w')

  bm.report do
    n.times { |i| @bucket.open("file", "r") }
  end

  reset
  @grid.open("file", 'w').close

  bm.report do
    n.times { |i| @grid.open("file", "r") }
  end
end

profile("Open a file in w mode", n: [1000, 5_000]) do |bm, n|
  reset

  bm.report do
    n.times { |i| @bucket.open("file", "w") }
  end

  reset

  bm.report do
    n.times { |i| @grid.open("file", "w") }
  end
end

def write_sample_file(klass)
  file = klass.open("file", 'w')
  file.write(content)
  file.close if file.respond_to?(:close)

  klass.open("file", "r")
end

profile("Read a whole file from the beginning", n: 100) do |bm, n|
  reset
  file = write_sample_file(@bucket)

  bm.report do
    n.times { |i| file.seek(0); file.read }
  end

  reset
  file = write_sample_file(@grid)

  bm.report do
    n.times { |i| file.seek(0); file.read }
  end
end

profile("Read 100 bytes a time till the end", n: [10, 100]) do |bm, n|
  reset
  file = write_sample_file(@bucket)

  bm.report do
    n.times do |i|
      file.seek(0)
      while !file.eof?; file.read(100); end
    end
  end

  reset
  file = write_sample_file(@grid)

  bm.report do
    n.times do |i|
      file.seek(0)
      while !file.eof?; file.read(100); end
    end
  end
end
