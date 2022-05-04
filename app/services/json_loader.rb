require 'open-uri'
require 'oj'

class JsonLoader
  def self.load(url, options = {})
    res = URI.open(url, options, &:read)

    Oj.load(res)
  end
end