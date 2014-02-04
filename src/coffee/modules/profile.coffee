angular = require 'angular'


module = angular.module 'tt.profile', ['ngRoute']

module.controller 'profileController', ($scope, user) ->
  $scope.user = user



module.config ($routeProvider, $locationProvider) ->
  $routeProvider
    .when '/profile',
      templateUrl: 'profile/index.html'
      controller: 'profileController'
      resolve:
        user: (userService) -> userService.getCurrentUser()
