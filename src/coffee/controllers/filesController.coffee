angular = require 'angular'
_ = require 'underscore'

module.exports = ($scope, $routeParams, userService, fileService, $firebase, $location, user, $window, ngProgress) ->
  $scope.user = user

  $scope.delete = (item) ->
    item.file.$remove().then () ->
      $location.path '/'

  ngProgress.start()

  fileIds = $routeParams.id.split(',')

  $scope.files = []

  _.each fileIds, (fileId) ->

    fileQuery = fileService.files.child fileId

    fileQuery.on 'value', (snapshot) ->
      fileObj = {}
      $scope.files.push fileObj

      if fileIds.length is $scope.files.length
        ngProgress.complete()

      fileObj.$priority = snapshot.getPriority()
      fileObj.$name = snapshot.name()

      fileObj.file = snapshot.val()
      fileObj.user = $firebase userService.users.child fileObj.file.user_id

  getFile = (currentFile, methodName) ->
    query = fileService.files[methodName](currentFile.$priority).limit 2
    query.on 'value', (snapshot) ->
      nextFile = _.omit snapshot.val(), currentFile.$name
      keys = _.keys(nextFile)
      return if keys.length is 0

      $scope.$apply ->
        $location.path '/files/' + _.first(keys)

  handleKeys = (e) ->
    currentFile = _.last $scope.files
    return unless e.keyCode in [37, 39] and currentFile.file?
    e.preventDefault()

    getFile(currentFile, 'endAt') if e.keyCode is 39
    getFile(currentFile, 'startAt') if e.keyCode is 37

  angular.element($window).on 'keydown', handleKeys

  $scope.$on '$destroy', ->
    angular.element($window).off 'keydown', handleKeys
