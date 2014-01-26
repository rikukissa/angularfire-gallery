module.exports = ($scope, $modal, userService, $rootScope) ->
  $scope.auth = userService.auth

  $rootScope.$on '$firebaseSimpleLogin:login', ->
    $scope.user = userService.users.$child $scope.auth.user.id

  $scope.logout = ->
    @auth.$logout()
