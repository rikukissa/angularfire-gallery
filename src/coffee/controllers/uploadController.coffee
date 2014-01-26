_ = require 'underscore'

module.exports = ($scope, $location, userService, imgurService, fileService, $firebase, youtubeService) ->
  $scope.auth = userService.auth

  $scope.$on '$destroy', ->
    console.log 'destruction'

  $scope.youtubeId = youtubeService.youtubeId
  $scope.isYoutubeUrl = youtubeService.isYoutubeUrl

  $scope.reset = ->
    @file = null
    @url = null
    @base64 = null
    @filePreview = null
    @submitting = false
    @error = null

  $scope.close = ->
    @reset()
    @$hide()

  $scope.reset()

  $scope.onFilePaste = ($files) ->
    return unless $files? and $files.length > 0
    dataUrl = _.first($files)
    @base64 = dataUrl.substr(dataUrl.indexOf('iVBOR'))
    @filePreview = dataUrl

  $scope.onFileSelect = ($files) ->
    return unless $files? and $files.length > 0
    @file = _.first $files

    # Create preview
    return if not window.FileReader? or @file.type.indexOf('image') is -1

    fileReader = new window.FileReader
    fileReader.readAsDataURL @file

    fileReader.onload = (e) =>
      @$apply =>
        @filePreview = e.target.result

  $scope.saveImage = (file) ->
    $scope.submitting = false
    fileModel = _.extend file,
      user_id: $scope.auth.user.id
      file_type: 'image'

    $firebase(fileService.files).$add(fileModel)
    .then (file) =>
      @close()
      $location.path '/files/' + file.name()

  $scope.saveVideo = (video) ->
    id = @youtubeId video

    return @showError 'INVALID_YOUTUBE_ID' unless id?

    fileModel =
      video: id
      user_id: $scope.auth.user.id
      file_type: 'video'
      link: video

    $firebase(fileService.files).$add(fileModel)
    .then (file) =>
      @close()
      $location.path '/files/' + file.name()


  $scope.showError = (err) ->
    @submitting = false
    @error = err

  $scope.submit = ->
    unless @file? or @url? or @base64?
      return @error = 'NOTHING_SELECTED'

    @submitting = true
    @error = null

    # Send file to Imgur
    if @file?
      return imgurService.postFile(@file)
        .then (res) =>
          @saveImage res.data.data
        , ({data}) =>
          @showError data.data.error

    # Send URL to Imgur
    if @url?
      if @isYoutubeUrl @url
        return @saveVideo @url

      return imgurService.postUrl(@url)
      .then (res) =>
        @saveImage res.data.data
      , ({data}) =>
        @showError data.data.error

    # Send base64 to imgur
    return imgurService.postBase64(@base64)
    .then (res) =>
      @saveImage res.data.data
    , ({data}) =>
      @showError data.data.error

