require "./papers/*"

require "markdown"
require "kemal"
require "rocksdb"

papers = RocksDB::DB.new("/tmp/db1")

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
