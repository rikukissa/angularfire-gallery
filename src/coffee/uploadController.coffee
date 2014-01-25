_ = require 'underscore'
module.exports = ($scope, $modalInstance, $location, userService, imgurService, fileService, $firebase) ->
  $scope.auth = userService.auth

  throw new Error 'user not logged in' unless $scope.auth.user?

  $scope.file = null
  $scope.submitting = false
  $scope.error = null

  $scope.close = ->
    $modalInstance.close()

  $scope.submit = ->
    $scope.submitting = true
    $scope.error = null

    imgurService.postFile(@file)
      .then (res) =>
        $scope.submitting = false

        file = res.data.data

        fileModel = _.extend(file, user_id: $scope.auth.user.id)

        $firebase(fileService.files).$add(fileModel)
        .then (file)->
          $modalInstance.close()
          $location.path '/files/' + file.name()

        , ->
          console.log arguments

      , ({data}) ->
        $scope.submitting = false
        $scope.error = data.data.error
