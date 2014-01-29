URI = require 'URIjs'

module.exports = () ->

  isYoutubeUrl: (url) ->
    URI(url).domain() is 'youtube.com'

  youtubeId: (url) ->
    URI(url).search(true).v

  getThumbnail: (url) ->
    id = @youtubeId url
    "http://img.youtube.com/vi/#{id}/mqdefault.jpg"
