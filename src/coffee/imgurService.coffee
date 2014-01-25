module.exports = ($http, $upload) ->

  $http.defaults.headers.common['Authorization'] = 'Client-ID 4dd0360487c151f'

  imageEndpoint = 'https://api.imgur.com/3/image'

  postFile: (file) ->
    $upload.upload
      url: imageEndpoint
      file: file
      headers:
        'Authorization':'Client-ID 4dd0360487c151f'
      data:
        type: 'file'
      fileFormDataName: 'image'

  postUrl: (url) ->
    $http.post imageEndpoint,
      image: url
      type: 'URL'
