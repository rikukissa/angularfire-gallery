module.exports = ($scope, $modalInstance, userService) ->
  $scope.auth = userService.auth

  $scope.loggingIn = false
  $scope.loginVisible = true
  $scope.loginError = false

  $scope.email = ''
  $scope.password = ''

  $scope.close = ->
    $modalInstance.close()

  $scope.login = ->
    @loginError = null
    @loggingIn = true

    @auth.$login 'password',
      email: @email
      password: @password
    .then (user) =>
      @loggingIn = false
      @close()

    , (err) =>
      @loggingIn = false
      @loginError = err.code
