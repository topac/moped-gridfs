# moped-gridfs

Add [GridFS support](http://docs.mongodb.org/manual/core/gridfs) to the [Moped driver](https://github.com/mongoid/moped).

Moped is a fast MongoDB driver for Ruby,
but it does not implement the GridFS specifications
(while [mongo-ruby-driver](https://github.com/mongodb/mongo-ruby-driver) does).

## Bucket

GridFS places the collections in a common bucket by prefixing each with the bucket name.
By default, GridFS uses two collections with names prefixed by "fs" bucket: _fs.files_ and _fs.chunks_.

You can choose a different bucket name than "fs", and create multiple buckets in a single database.  
Access the default bucket (named "fs") this way:

```ruby
  require 'moped'
  require 'moped/gridfs'

  session = Moped::Session.new(["127.0.0.1:27017"])
  session.use("test")
  bucket = session.bucket #<Moped::GridFS::Bucket:7ffbdbd4e160 name=fs>
```
or
```ruby
  bucket = Moped::GridFS::Bucket.new(session) #<Moped::GridFS::Bucket:7fc06db72c00 name=fs>
```

A list of all the buckets can be retrieved with `Session#buckets`.
For example, you can access the _photos_ bucket with `session.buckets['photos']`.

To open a file call `Bucket#open`, with the filename (or the _id) and the open mode.
A more generic selector can be also given instead of the filename.

## File

The GridFS::File class exposes an API similar to the ruby File class.

```ruby
  file = bucket.open("myfile", "w+") #<Moped::GridFS::File:7f88599a58b0 bucket=fs _id=539c532ddb13a973ed000001 mode=w+ filename=myfile length=0>
  file.write("foobar") # 6
  file.seek(3) # 3
  file.read # "bar"
```

All the [open modes](http://www.ruby-doc.org/core-2.1.2/IO.html#method-c-new-label-IO+Open+Mode) are supported:
r, r+, w, w+, a and a+.

GridFS::File attributes are: _id, length, chunk_size, filename, content_type, md5, aliases, metadata and uploadDate.
Some of them may be changed if the file is opened in write/append mode.

```ruby
  file.content_type # "application/octet-stream"
  file.md5 # "3858f62230ac3c915f300c664312c63f"
  file.filename = "test"
  file.filename # "test"
```

## Thread safe?
It depends on what you're doing.  
You may face race conditions if many threads are writing on the same file a buffer that have to be splitted onto multiple chunks. This is due to how the GridFS specs have been designed: [read this](https://jira.mongodb.org/browse/NODE-157).

## Performance

Are pretty the same of mongo-ruby-driver (run the script perf/compare.rb).


## Installation

Add this line to your application's Gemfile:

    gem 'moped-gridfs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moped-gridfs


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
