_ = require 'underscore'
async = require 'async'
angular = require 'angular'

module.exports = ($scope, $route, $q, $window, $routeParams, $location, userService, fileService, user, ngProgress) ->
  $scope.files = []
  $scope.user = user

  lastRoute = $route.current
  $scope.$on '$locationChangeSuccess', (e, next, current) ->
    $route.current = lastRoute if next.indexOf('/files/') > 0

  cache =
    current: null
    prev: []
    next: []

  cachePromises =
    init: null
    next: null
    prev: null

  $scope.delete = (file) ->
    fileService
      .removeFile(file.$name)
      .then ->
        return $window.history.back() if $window.history > 1
        $location.path '/'

  addFile = (file) ->
    $scope.files.push file

    $location.path 'files/' + _.map $scope.files, (file) ->
      file.$name
    .join ','

    userService.getUser(file.user_id).then (user) ->
      file.user = user

  ngProgress.start()

  fileIds = $routeParams.id.split(',')

  # Load files
  async.map fileIds, (id, callback) ->

    fileService.getFile(id).then (file) ->
      addFile file
      callback null, file
    , ->
      callback null

  , (err, results) ->
    ngProgress.complete()

    results = _.filter results, _.identity

    return $location.path '/404' if results.length is 0

    cachePromises.init = initializeCache()

  # Loads next & previous files to cache
  initializeCache = ->
    cache.current = _.last($scope.files)

    priority = cache.current.$priority

    next = fileService.getNext priority
    prev = fileService.getPrevious priority

    $q.all([prev, next]).then ([prev, next]) ->
      cache.next = next
      cache.prev = prev

  moveToFile = (direction) ->
    cachePromises.init.then ->
      return if cache[direction].length is 0

      # Push current file to previous files
      prevDirection = if direction is 'next' then 'prev' else 'next'

      cache[prevDirection].unshift cache.current

      # Set next file to be the current file
      cache.current = cache[direction].shift()

      $scope.files = []

      addFile cache.current

      return if cachePromises[direction]? or cache[direction].length >= 5

      # Start fetching for next 5 files
      lastFile = _.last(cache[direction])

      return unless lastFile?

      priority = lastFile.$priority

      cachePromises[direction] = fileService.getNext(priority)
        .then (files) ->
          cache[direction] = cache[direction].concat files

          cachePromises[direction] = null

  handleKeys = (e) ->
    return unless e.keyCode in [37, 39] and cachePromises.init?

    e.preventDefault()

    moveToFile('next') if e.keyCode is 39
    moveToFile('prev') if e.keyCode is 37

  angular.element($window).on 'keydown', handleKeys

  $scope.$on '$destroy', ->
    angular.element($window).off 'keydown', handleKeys
