module.exports = ($scope, $modalInstance, userService) ->
  $scope.auth = userService.auth
  $scope.username =
  $scope.email = null
  $scope.password = null

  $scope.close = ->
    $modalInstance.close()

  $scope.signup = ->
    userService.create
      email: @email
      password: @password
      username: @username
    .then ->

