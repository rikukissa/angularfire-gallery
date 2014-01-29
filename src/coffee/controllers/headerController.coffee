module.exports = ($scope, $rootScope, $firebase, $dropdown, userService) ->
  $scope.auth = userService.auth

  $scope.dropdown = [
      'text': 'Log out'
      'click': 'logout()'
  ]

  $rootScope.$on '$firebaseSimpleLogin:login', ->
    $scope.user = $firebase userService.user

  $rootScope.$on '$firebaseSimpleLogin:logout', ->
    $scope.user = null

  $scope.logout = ->
    @auth.$logout()
