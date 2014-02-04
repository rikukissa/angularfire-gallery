_ = require 'underscore'

module.exports = ($timeout, $route, $scope, $rootScope, $location, $firebase, fileService, youtubeService, user, ngProgress) ->
  ngProgress.start()
  $scope.user = user
  $scope.files = []

  fileCache = []

  loadingFiles = true

  INITIAL_FETCH_AMOUNT = 150
  INFINITE_SCROLL_FETCH_AMOUNT = 50

  if $location.search()?.p?
    promise = fileService.getNext parseInt($location.search().p), INITIAL_FETCH_AMOUNT
  else
    promise = fileService.getNewFiles INITIAL_FETCH_AMOUNT

  promise.then (files) ->
    ngProgress.complete()
    loadingFiles = false

    fileCache = files.splice -Math.floor INITIAL_FETCH_AMOUNT / 3
    $scope.files = files

  setPath = ->
    lastVisibleFile = $scope.files[$scope.files.length - 1 - INFINITE_SCROLL_FETCH_AMOUNT - INITIAL_FETCH_AMOUNT]
    lastVisibleFile ?= _.first $scope.files
    $location.search 'p', lastVisibleFile.$priority

  $scope.loadMore = ->


    # Empty cache files to view
    if fileCache.length > 0
      $scope.files = $scope.files.concat fileCache
      fileCache = []

    return if loadingFiles

    ngProgress.reset()
    ngProgress.start()

    loadingFiles = true

    lastPriority = _.last($scope.files).$priority

    fileService.getNext(lastPriority, INFINITE_SCROLL_FETCH_AMOUNT).then (newFiles) ->
      ngProgress.complete()
      loadingFiles = false

      fileCache = newFiles.splice -Math.floor INFINITE_SCROLL_FETCH_AMOUNT / 2
      $scope.files = $scope.files.concat newFiles

      setPath()
