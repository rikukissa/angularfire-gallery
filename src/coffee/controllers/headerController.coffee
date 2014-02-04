module.exports = ($scope, $location, $rootScope, $firebase, $dropdown, userService) ->

  $scope.dropdown = [
      'text': 'Profile'
      'href': '#/profile'
    ,
      'text': 'Log out'
      'href': '#/logout'
  ]

  $scope.showSettings = ($event) ->
    console.log arguments
