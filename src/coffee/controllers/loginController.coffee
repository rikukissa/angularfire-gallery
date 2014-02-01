module.exports = ($scope, $location, $modal, userService) ->
  modal = $modal
    scope: $scope
    template: 'login.html'
    placement: 'center'
    animation: 'animation-fadeAndScale'
    backdrop: 'static'
    container: 'body'
    keyboard: false

  $scope.loggingIn = false
  $scope.loginVisible = true
  $scope.loginError = false

  $scope.email = null
  $scope.password = null

  $scope.login = ->
    @loginError = null
    @loggingIn = true

    userService.authenticate(@email, @password).then (user) =>
      $location.path '/'
    , (err) =>
      @loggingIn = false
      @loginError = err.code

  $scope.$on '$destroy', ->
    modal.destroy()
