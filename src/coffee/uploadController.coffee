_ = require 'underscore'
module.exports = ($scope, $location, userService, imgurService, fileService, $firebase) ->
  $scope.auth = userService.auth

  $scope.$on '$destroy', ->
    console.log 'destruction'

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

  $scope.save = (file) ->
    $scope.submitting = false
    fileModel = _.extend(file, user_id: $scope.auth.user.id)

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
          @save res.data.data
        , ({data}) =>
          @showError data.data.error

    # Send URL to Imgur
    if @url?
      return imgurService.postUrl(@url)
      .then (res) =>
        @save res.data.data
      , ({data}) =>
        @showError data.data.error

    # Send base64 to imgur
    return imgurService.postBase64(@base64)
    .then (res) =>
      @save res.data.data
    , ({data}) =>
      @showError data.data.error

