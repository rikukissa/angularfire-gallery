_ = require 'underscore'
async = require 'async'
angular = require 'angular'


module = angular.module 'tt.profile', ['ngRoute']

module.controller 'profileController', ($scope, user, profile) ->
  $scope.user = user
  $scope.profile = profile
  $scope.profile ?= user

module.controller 'profileFilesController', ($scope, user, profile, fileService, ngProgress) ->
  $scope.user = user
  $scope.profile = profile
  $scope.profile ?= user

  $scope.files = []

  ngProgress.start()

  async.map _.keys($scope.profile.files), (item, callback) ->
    fileService.getFile(item).then (item) ->
      $scope.files.push item
      callback null
  , ->
    ngProgress.complete()

module.controller 'profileFavouritesController', ($scope, user, profile, fileService, ngProgress) ->
  $scope.user = user
  $scope.profile = profile
  $scope.profile ?= user

  $scope.files = []

  ngProgress.start()

  async.map _.keys($scope.profile.favourites), (item, callback) ->
    fileService.getFile(item).then (item) ->
      $scope.files.push item
      callback null
  , ->
    ngProgress.complete()


module.controller 'profileSettingsController', ($scope, $timeout, user, profile) ->
  $scope.user = user
  $scope.profile = profile
  $scope.profile ?= user

  $scope.userSaved = false
  $scope.userError = null

  $scope.saveUser = ->
    @user.$save().then =>
      @userSaved = true
      $timeout =>
        @userSaved = false
      , 4000
    , =>
      console.log arguments


module.directive 'sidebar', require '../directives/sidebar.coffee'

resolvers =
  user: (userService) -> userService.getCurrentUser()
  profile: ($q, userService, $route) ->
    if $route.current.params.id
      return userService.getUser parseInt $route.current.params.id

    deferred = $q.defer()
    deferred.resolve null
    deferred.promise


module.config ($routeProvider, $locationProvider) ->
  $routeProvider
    # Routes for profile
    .when '/profile/',
      templateUrl: 'profile/index.html'
      controller: 'profileController'
      resolve: resolvers

    .when '/profile/uploads',
      templateUrl: 'profile/files.html'
      controller: 'profileFilesController'
      resolve: resolvers

    .when '/profile/settings',
      templateUrl: 'profile/settings.html'
      controller: 'profileSettingsController'
      resolve: resolvers

    .when '/profile/favourites',
      templateUrl: 'profile/favourites.html'
      controller: 'profileFavouritesController'
      resolve: resolvers

    # Routes for external user
    .when '/user/:id',
      templateUrl: 'profile/index.html'
      controller: 'profileController'
      resolve: resolvers

    .when '/user/:id/uploads',
      templateUrl: 'profile/files.html'
      controller: 'profileFilesController'
      resolve: resolvers

    .when '/user/:id/favourites',
      templateUrl: 'profile/favourites.html'
      controller: 'profileFavouritesController'
      resolve: resolvers
