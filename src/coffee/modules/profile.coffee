angular = require 'angular'


module = angular.module 'tt.profile', ['ngRoute']

module.controller 'profileController', ($scope, user) ->
  $scope.user = user

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

module.config ($routeProvider, $locationProvider) ->
  $routeProvider
    .when '/profile',
      templateUrl: 'profile/index.html'
      controller: 'profileController'
      resolve:
        user: (userService) -> userService.getCurrentUser()

    .when '/profile/settings',
      templateUrl: 'profile/settings.html'
      controller: 'profileSettingsController'
      resolve:
        user: (userService) -> userService.getCurrentUser()
