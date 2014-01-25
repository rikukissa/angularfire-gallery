module.exports = ($http, $upload) ->

  $http.defaults.headers.common['Authorization'] = 'Client-ID 4dd0360487c151f'

  postFile: (file) ->
    $upload.upload
      url: 'https://api.imgur.com/3/image'
      file: file
      headers:
        'Authorization':'Client-ID 4dd0360487c151f'
      data:
        type: 'file'
      fileFormDataName: 'image'
