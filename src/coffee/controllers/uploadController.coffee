_ = require 'underscore'
Firebase = require 'firebase'

module.exports = ($scope, $q, $location, $routeParams, userService, imgurService, fileService, $firebase, youtubeService, $timeout) ->
  $scope.auth = userService.auth

  if $location.$$path is '/upload'
    $scope.$watch '$$childHead', (scope) ->
      scope.$show()

  $scope.reset = ->
    @preview =
      file: null
      url: null
      paste: null
      youtube: null
      drop: null
    @data =
      file: null
      url: null
      paste: null
      youtube: null
      drop: null

    @submitting = false
    @error = null

  $scope.close = ->
    @reset()
    @$hide()

  $scope.reset()

  # Event handlers
  $scope.urlChange = ->
    if @data.url?
      return @preview.url = @data.url
    @preview.url = null

  $scope.youtubeChange = ->
    if @data.youtube?
      @preview.youtube = youtubeService.getThumbnail @data.youtube
      return
    @preview.youtube = null

  $scope.onFilePaste = ($files) ->
    return unless $files? and $files.length > 0
    dataUrl = _.first($files)
    @preview.paste = dataUrl
    @data.paste = dataUrl.substr(dataUrl.indexOf('iVBOR'))

  $scope.onFileDrop = ($files) ->
    @onFileSelect $files, true

  $scope.onFileSelect = ($files, drop = false) ->
    return unless $files? and $files.length > 0

    target = if drop then 'drop' else 'file'

    @data[target] = _.first $files

    # Create preview
    return if not window.FileReader? or @data[target].type.indexOf('image') is -1

    fileReader = new window.FileReader
    fileReader.readAsDataURL @data[target]

    fileReader.onload = (e) =>
      @$apply =>
        @preview[target] = e.target.result

  $scope.saveImage = (file) ->
    fileService.create
      link: file.link
      user_id: $scope.auth.user.id
      file_type: 'image'
      service: 'imgur'
      thumbnail: imgurService.getThumbnail file.link

  $scope.saveVideo = (video) ->
    id = youtubeService.youtubeId video

    throw new Error 'Invalid Youtube id' unless id?

    fileService.create
      video: id
      user_id: $scope.auth.user.id
      file_type: 'video'
      link: video
      service: 'youtube'
      thumbnail: youtubeService.getThumbnail video

  $scope.submit = ->
    unless  _.some(@data, (data) ->
      data?
    )
      return @error = 'Nothing to upload'

    @submitting = true
    @error = null

    save = _.bind @saveImage, @

    promises = []

    if @data.file?
      promises.push imgurService.postFile(@data.file).then save

    if @data.drop?
      promises.push imgurService.postFile(@data.drop).then save

    if @data.url?
      promises.push imgurService.postUrl(@data.url).then save

    if @data.paste?
      promises.push imgurService.postBase64(@data.paste).then save

    if @data.youtube?
      promises.push @saveVideo @data.youtube

    $q.all(promises)
      .then (results) =>
        @submitting = false

        savedFiles = _.map results, (result) ->
          result.name()

        # Get current
        userService.getCurrentUser().then (user) ->
          user.files[file] = true for file in savedFiles
          user.$save()
        .then =>
          $location.path '/files/' + savedFiles.join ','
          @close()

      , (error) =>
        @submitting = false
        @error = error.message

