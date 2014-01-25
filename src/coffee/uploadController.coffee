_ = require 'underscore'
module.exports = ($scope, $modalInstance, $location, userService, imgurService, fileService, $firebase) ->
  $scope.auth = userService.auth

  throw new Error 'user not logged in' unless $scope.auth.user?

  $scope.file = null
  $scope.url = null

  $scope.submitting = false
  $scope.error = null

  $scope.close = ->
    $modalInstance.close()


  save = (file) ->
    $scope.submitting = false
    fileModel = _.extend(file, user_id: $scope.auth.user.id)

    $firebase(fileService.files).$add(fileModel)
    .then (file)->
      $modalInstance.close()
      $location.path '/files/' + file.name()


  showError = (err) ->
    $scope.submitting = false
    $scope.error = err

  $scope.submit = ->
    unless @file? or @url?
      return @error = 'NOTHING_SELECTED'

    @submitting = true
    @error = null

    # Send file to Imgur
    if @file?
      return imgurService.postFile(@file)
        .then (res) =>
          save res.data.data
          , ->
            console.log arguments
        , ({data}) ->
          showError data.data.error

    # Send URL to Imgur
    imgurService.postUrl(@url)
      .then (res) =>
        console.log res
        save res.data.data
      , ({data}) ->
        showError data.data.error
