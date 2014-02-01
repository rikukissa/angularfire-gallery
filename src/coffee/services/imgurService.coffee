_ = require 'underscore'
path = require 'path'
config = require '../config.coffee'

module.exports = ($http, $upload, $q) ->

  clientId = 'Client-ID ' + config.imgur.clientId

  $http.defaults.headers.common['Authorization'] = clientId

  imageEndpoint = 'https://api.imgur.com/3/image'

  defaults = {}
  defaults.album = config.imgur.album if config.imgur.album?

  getThumbnail: (url) ->
    basename = path.basename url, path.extname(url)
    url.replace basename, basename + 'b'

  postFile: (file) ->
    $q.when($upload.upload(
      url: imageEndpoint
      file: file
      headers:
        'Authorization': clientId
      data: _.extend(defaults, type: 'file')
      fileFormDataName: 'image'
    )).then (response) ->
      response.data.data
    , (response) ->
      throw new Error response.data.data.error

  postUrl: (url) ->
    $http.post(imageEndpoint, _.extend defaults,
      image: url
      type: 'URL'
    ).then (response) ->
      response.data.data
    , (response) ->
      throw new Error response.data.data.error

  postBase64: (base64) ->
    $http.post(imageEndpoint, _.extend defaults,
      image: base64
      type: 'base64'
    ).then (response) ->
      response.data.data
    , (response) ->
      if response.status is 404
        return throw new Error 'Upload failed'
      throw new Error response.data.data.error
