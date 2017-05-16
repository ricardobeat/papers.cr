require "./papers/*"

require "markdown"
require "kemal"

# require "redis"

# papers = Redis.new

require "rocksdb"
papers = RocksDB::DB.new("/tmp/db1")

# class TextDB
#   def initialize(@root : String)
#     @cache = {} of String => String
#     unless File.directory?(@root)
#       raise "#{@root} is afgeborked"
#     end
#   end

#   def file_path(id)
#     File.join(@root, "#{id}.md")
#   end

#   def get(id)
#     path = file_path(id)
#     return @cache[id] if @cache[id]?
#     if File.file?(path)
#       content = File.read(path)
#       @cache[id] = content
#     end
#   end

#   def put(id, content)
#     path = file_path(id)
#     File.write(path, content)
#   end
# end

# Collaborative editing
#
# 1. document is put in edit mode, counter = 0
# 2. each client receives the counter
# 3. counter is sent with every operation
# 4. on receive, counter is set to received value
#
# server:
#
# queue operations, apply in order
#
# if op counter < previous counter
#   apply transformation
# else
#   apply op
# end
#
#
#
#

# papers = TextDB.new("./db")

def extract_title(content)
  content ? content.lines[0].gsub(/[\W\S]/, "") : "Untitled"
end

get "/:id" do |env|
  id = env.params.url["id"]
  title = ""
  if pad = papers.get?(id)
    title = extract_title(pad)
    render "src/views/paper.ecr", "src/views/layout.ecr"
  else
    pad_content = ""
    render "src/views/edit.ecr", "src/views/layout.ecr"
  end
end

get "/:id/edit" do |env|
  id = env.params.url["id"]
  pad_content = papers.get(id)
  title = extract_title(pad_content)
  render "src/views/edit.ecr", "src/views/layout.ecr"
end

post "/:id" do |env|
  id = env.params.url["id"]
  papers.put(id, env.params.body["pad"])
  env.redirect "/#{id}"
end

# SOCKETS

CLIENTS = [] of HTTP::WebSocket

def broadcast(message)
  CLIENTS.each &.send(message)
end

ws "/socket" do |socket|
  CLIENTS << socket

  socket.on_close do
    CLIENTS.delete socket
  end

  socket.on_message do |message|
    broadcast(message)
  end
end

Kemal.run
