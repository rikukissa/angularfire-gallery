angular = require 'angular'
_ = require 'underscore'
async = require 'async'

module.exports = ($scope, $routeParams, userService, fileService, $firebase, $location, user, $window, ngProgress) ->
  $scope.files = []
  $scope.user = user

  $scope.delete = (file) ->
    fileService
      .removeFile(file.$name)
      .then ->
        return $window.history.back() if $window.history > 1
        $location.path '/'

  ngProgress.start()

  fileIds = $routeParams.id.split(',')

  # Load files
  async.map fileIds, (id, callback) ->

    fileService.getFile(id).then (file) ->
      $scope.files.push file
      callback null, file
    , ->
      callback null

  , (err, results) ->
    ngProgress.complete()

    results = _.filter results, _.identity
    $location.path '/404' if results.length is 0


  # Browsing
  getFile = (currentFile, methodName) ->
    query = fileService.files[methodName](currentFile.$priority).limit 2
    query.once 'value', (snapshot) ->
      nextFile = _.omit snapshot.val(), currentFile.$name
      keys = _.keys(nextFile)
      return if keys.length is 0

      $scope.$apply ->
        $location.path '/files/' + _.first(keys)

  handleKeys = (e) ->
    currentFile = _.last $scope.files
    return unless e.keyCode in [37, 39] and currentFile?
    e.preventDefault()

    getFile(currentFile, 'endAt') if e.keyCode is 39
    getFile(currentFile, 'startAt') if e.keyCode is 37

  angular.element($window).on 'keydown', handleKeys

  $scope.$on '$destroy', ->
    angular.element($window).off 'keydown', handleKeys
