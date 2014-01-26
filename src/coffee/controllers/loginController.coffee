module.exports = ($scope, userService) ->
  $scope.auth = userService.auth

  $scope.loggingIn = false
  $scope.loginVisible = true
  $scope.loginError = false

  $scope.email = null
  $scope.password = null

  $scope.close = ->
    @email = @password = null
    @$hide()

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
