_ = require 'underscore'

config = require './config.coffee'

module.exports = ($http, $upload) ->

  clientId = 'Client-ID ' + config.imgur.clientId

  $http.defaults.headers.common['Authorization'] = clientId

  imageEndpoint = 'https://api.imgur.com/3/image'

  postFile: (file) ->
    $upload.upload
      url: imageEndpoint
      file: file
      headers:
        'Authorization': clientId
      data:
        type: 'file'

      fileFormDataName: 'image'

  postUrl: (url) ->
    $http.post imageEndpoint,
      image: url
      type: 'URL'

  postBase64: (base64) ->
    $http.post imageEndpoint,
      image: base64
      type: 'base64'
