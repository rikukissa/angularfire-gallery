module.exports = ($scope, userService) ->
  $scope.auth = userService.auth
  $scope.username =
  $scope.email = null
  $scope.password = null
  $scope.signingUp = false

  $scope.close = ->
    @email = @password = @username = null
    @$hide()

  $scope.signup = ->
    @signingUp = true

    userService.create
      email: @email
      password: @password
      username: @username
    .then =>
      @signingUp = false
      @close()
    , (err) =>
      console.log arguments
