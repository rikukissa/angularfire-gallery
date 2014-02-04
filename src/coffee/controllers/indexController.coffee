_ = require 'underscore'

module.exports = ($timeout, $route, $scope, $rootScope, $location, $firebase, fileService, youtubeService, user, ngProgress) ->
  ngProgress.start()
  $scope.user = user
  $scope.files = []

  fileCache = []

  loadingFiles = true

  if $location.search()?.p?
    promise = fileService.getNext parseInt($location.search().p), 150
  else
    promise = fileService.getNewFiles 150

  promise.then (files) ->
    ngProgress.complete()
    loadingFiles = false

    fileCache = files.splice -50
    $scope.files = files

  $scope.loadMore = ->

    # Empty cache files to view
    if fileCache.length > 0
      $location.search 'p', _.last($scope.files).$priority
      $scope.files = $scope.files.concat fileCache
      fileCache = []

    return if loadingFiles

    ngProgress.reset()
    ngProgress.start()

    loadingFiles = true

    lastPriority = _.last($scope.files).$priority

    fileService.getNext(lastPriority, 50).then (newFiles) ->
      ngProgress.complete()
      loadingFiles = false

      fileCache = newFiles.splice -25
      $scope.files = $scope.files.concat newFiles
