$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "moped/gridfs"
require "rspec"
require "pry"
require "java" if RUBY_PLATFORM == "java"

ENV["MOPED-GRIDFS_SPEC_HOST"] ||= "127.0.0.1"
ENV["MOPED-GRIDFS_SPEC_PORT"] ||= "27017"
ENV["MOPED-GRIDFS_SPEC_DB"]   ||= "moped-gridfs-test"

def moped_session
  addr = ENV["MOPED-GRIDFS_SPEC_HOST"] + ":" + ENV["MOPED-GRIDFS_SPEC_PORT"]

  session = Moped::Session.new([addr])
  session.use(ENV["MOPED-GRIDFS_SPEC_DB"])
  session
end

def drop_all_collections
  moped_session.collections.each(&:drop)
end

RSpec.configure do |config|
  config.before(:each) do
    drop_all_collections
  end

  config.after(:all) do
    drop_all_collections
  end
end
