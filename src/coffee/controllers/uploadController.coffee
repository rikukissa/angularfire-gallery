_ = require 'underscore'
Firebase = require 'firebase'

module.exports = ($scope, $q, $location, userService, imgurService, fileService, $firebase, youtubeService) ->
  $scope.auth = userService.auth

  $scope.youtubeId = youtubeService.youtubeId
  $scope.isYoutubeUrl = youtubeService.isYoutubeUrl
  $scope.youtubeThumbnail = youtubeService.getThumbnail

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

  $scope.save = (model) ->
    model.timestamp = Firebase.ServerValue.TIMESTAMP
    deferred = $q.defer()

    ref = fileService.files.push model, (err) ->
      deferred.reject err if err?
      deferred.resolve ref

    deferred.promise

  $scope.saveImage = (file) ->
    @save
      link: file.link
      user_id: $scope.auth.user.id
      file_type: 'image'
      service: 'imgur'
      thumbnail: imgurService.getThumbnail file.link

  $scope.saveVideo = (video) ->
    id = @youtubeId video
    throw new Error 'Invalid Youtube id' unless id?

    @save
      video: id
      user_id: $scope.auth.user.id
      file_type: 'video'
      link: video
      service: 'youtube'
      thumbnail: youtubeService.getThumbnail video

  $scope.submit = ->
    unless @file? or @url? or @base64?
      return @error = 'Nothing to upload'

    @submitting = true
    @error = null

    save = _.bind @saveImage, @

    promises = []

    if @file?
      console.log @file
      promises.push imgurService.postFile(@file).then save

    if @url?
      if @isYoutubeUrl @url
        promises.push @saveVideo @url
      else
        # Send file to Imgur
        promises.push imgurService.postUrl(@url).then save

    # Send base64 to imgur
    if @base64?
      promises.push imgurService.postBase64(@base64).then save

    $q.all(promises)
      .then (results) =>
        @submitting = false
        $location.path '/files/' + _.map(results, (result) ->
          result.name()
        ).join ','

        @close()

      , (error) =>
        @submitting = false
        @error = error.message

