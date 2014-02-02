_ = require 'underscore'

module.exports = ($scope, $location, $modal, userService, fileService) ->
  # Load background image from public files
  fileService.getPublicFiles().then (files) ->
    return if files.length is 0
    $scope.previewSrc = _.sample(files).link

  # Login modal
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
    modal.hide()
    modal.destroy()
