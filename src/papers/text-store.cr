class TextDB
  def initialize(@root : String)
    @cache = {} of String => String
    unless File.directory?(@root)
      raise "#{@root} is afgeborked"
    end
  end

  def file_path(id)
    File.join(@root, "#{id}.md")
  end

  def get(id)
    path = file_path(id)
    return @cache[id] if @cache[id]?
    if File.file?(path)
      content = File.read(path)
      @cache[id] = content
    end
  end

  def put(id, content)
    path = file_path(id)
    File.write(path, content)
  end
end
