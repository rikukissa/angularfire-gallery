module.exports = ($scope, $modal, userService, $rootScope, $dropdown) ->
  $scope.auth = userService.auth

  $rootScope.$on '$firebaseSimpleLogin:login', ->
    $scope.user = userService.users.$child $scope.auth.user.id

  $rootScope.$on '$firebaseSimpleLogin:logout', ->
    $scope.user = null

  $scope.dropdown = [
      'text': 'Log out'
      'click': 'logout()'
  ]

  $scope.logout = ->
    @auth.$logout()
