_ = require 'underscore'
async = require 'async'
angular = require 'angular'


module = angular.module 'tt.profile', ['ngRoute']

module.controller 'profileController', ($scope, user) ->
  $scope.user = user

module.controller 'profileFilesController', ($scope, user, fileService, ngProgress) ->
  $scope.user = user
  $scope.files = []

  ngProgress.start()

  async.map _.keys(user.files), (item, callback) ->
    fileService.getFile(item).then (item) ->
      $scope.files.push item
      callback null
  , ->
    ngProgress.complete()

module.controller 'profileFavouritesController', ($scope, user, fileService, ngProgress) ->
  $scope.user = user
  $scope.files = []

  ngProgress.start()

  async.map _.keys(user.favourites), (item, callback) ->
    fileService.getFile(item).then (item) ->
      $scope.files.push item
      callback null
  , ->
    ngProgress.complete()


module.controller 'profileSettingsController', ($scope, $timeout, user) ->
  $scope.user = user

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

module.config ($routeProvider, $locationProvider) ->
  $routeProvider
    .when '/profile/',
      templateUrl: 'profile/index.html'
      controller: 'profileController'
      resolve: resolvers

    .when '/profile/files',
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

    # .when '/profile/:userId',
    #   templateUrl: 'profile/index.html'
    #   controller: 'profileController'
    #   resolve: _.extend resolvers,
    #     externalUser: (userService, $route) ->
    #       userService.getUser parseInt $route.current.params.userId


