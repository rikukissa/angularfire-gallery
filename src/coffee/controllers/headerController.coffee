module.exports = ($scope, $modal, userService, $rootScope) ->
  $scope.auth = userService.auth

  $rootScope.$on '$firebaseSimpleLogin:login', ->
    $scope.user = userService.users.$child $scope.auth.user.id

  $rootScope.$on '$firebaseSimpleLogin:logout', ->
    console.log 'foo'
    $scope.user = null

  $scope.logout = ->
    @auth.$logout()
