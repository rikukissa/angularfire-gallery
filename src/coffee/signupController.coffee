module.exports = ($scope, $modalInstance, userService) ->
  $scope.auth = userService.auth
  $scope.username =
  $scope.email = null
  $scope.password = null
  $scope.signingUp = false

  $scope.close = ->
    $modalInstance.close()

  $scope.signup = ->
    @signingUp = true

    userService.create
      email: @email
      password: @password
      username: @username
    .then =>
      @signingUp = false
      @close()
