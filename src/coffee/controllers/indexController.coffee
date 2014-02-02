_ = require 'underscore'

module.exports = ($timeout, $route, $scope, $rootScope, $location, $firebase, fileService, youtubeService, user, ngProgress) ->
  ngProgress.start()
  $scope.user = user
  $scope.files = []

  fileCache = []

  loadingFiles = true

  orderFiles = (query) ->
    query = _.map query.$getIndex(), (index) ->
      _.extend query[index],
        $id: index

    _.sortBy query, (file) ->
      -file.timestamp

  # Load initial files
  query = fileService.files

  if $location.search()?.p?
    query = query.endAt parseInt $location.search().p

  query = query.limit 150

  files = $firebase query

  files.$on 'loaded', () ->
    loadingFiles = false
    files = orderFiles files
    fileCache = files.splice -50
    $scope.files = files

    ngProgress.complete()

  # Load more files on acroll
  $scope.loadMore = ->

    # Empty cache files to view
    if fileCache.length > 0
      $location.search 'p', _.last($scope.files).$priority
      $scope.files = $scope.files.concat fileCache
      fileCache = []

    return if loadingFiles

    loadingFiles = true

    lastPriority = _.last($scope.files).$priority

    fileQuery = $firebase fileService.files.endAt(lastPriority).limit 50

    ngProgress.reset()
    ngProgress.start()

    fileQuery.$on 'loaded', () ->
      newFiles = orderFiles fileQuery

      newFiles.shift()

      fileCache = newFiles.splice -25

      $scope.files = $scope.files.concat newFiles

      loadingFiles = false
      ngProgress.complete()

      # if $scope.files.length > 200
      #   $scope.files.splice 0, 50
