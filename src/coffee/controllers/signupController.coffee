module.exports = ($scope, $modal, $location, userService) ->
  modal = $modal
    scope: $scope
    template: 'signup.html'
    placement: 'center'
    animation: 'animation-fadeAndScale'
    backdrop: 'static'
    container: 'body'
    keyboard: false

  $scope.auth = userService.auth
  $scope.username = null
  $scope.email = null
  $scope.password = null
  $scope.signingUp = false

  $scope.close = ->
    @email = @password = @username = null
    $location.path '/login'
    modal.destroy()

  $scope.signup = ->
    @signingUp = true

    userService.create
      email: @email
      password: @password
      username: @username
    .then =>
      @signingUp = false
      modal.destroy()
      $location.path '/login'
    , (err) =>
      console.log arguments
