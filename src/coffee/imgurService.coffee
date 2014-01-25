_ = require 'underscore'

config = require './config.coffee'

module.exports = ($http, $upload) ->

  clientId = 'Client-ID ' + config.imgur.clientId

  $http.defaults.headers.common['Authorization'] = clientId

  imageEndpoint = 'https://api.imgur.com/3/image'

  defaults = {}
  defaults.album = config.imgur.album if config.imgur.album?

  postFile: (file) ->
    $upload.upload
      url: imageEndpoint
      file: file
      headers:
        'Authorization': clientId
      data: _.extend defaults, type: 'file'

      fileFormDataName: 'image'

  postUrl: (url) ->
    $http.post imageEndpoint, _.extend defaults,
      image: url
      type: 'URL'

  postBase64: (base64) ->
    $http.post imageEndpoint, _.extend defaults,
      image: base64
      type: 'base64'
