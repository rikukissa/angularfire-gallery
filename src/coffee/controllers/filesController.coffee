_ = require 'underscore'

module.exports = ($scope, $routeParams, userService, fileService, $firebase, $location) ->
  $scope.auth = userService.auth

  $scope.delete = ->
    @file.$remove().then () ->
      $location.path '/'

  fileIds = $routeParams.id.split(',')

  $scope.files = []

  _.each fileIds, (fileId) ->
    fileObj = {}

    $scope.files.push fileObj

    fileObj.file = $firebase fileService.files.child fileId

    fileObj.file.$on 'loaded', ->
      fileObj.user = $firebase userService.users.child fileObj.file.user_id
